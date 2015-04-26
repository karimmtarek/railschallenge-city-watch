class RespondersDispatcher
  attr_reader :emergency

  def initialize(emergency)
    @emergency = emergency
  end

  def dispatch
    return if resolved?

    dispatch_by_type
    calc_full_response
    assign_emergency_code
    save
  end

  def dispatch_by_type
    responders_types.each do |type|
      next unless severity_values[type.downcase] > 0
      responders_tbl = Responder.available_on_duty_by(type)
      dispatcher(responders_tbl, severity_values, type)
    end
  end

  def dispatcher(tbl, severity_hash, type)
    tbl.each_with_index do |responder, index|
      return add_responder(@emergency, responder, nil, nil) if index == tbl.length - 1

      next unless responder.capacity <= severity_hash[type.downcase]
      assign_responder(tbl, responder, index, severity_hash, type)

      break if severity_hash[type.downcase] <= 0
    end
  end

  def assign_responder(tbl, responder, index, severity_hash, type)
    if index == 0 || responder.capacity == severity_hash[type.downcase]
      add_responder(@emergency, responder, severity_hash, type)
    elsif tbl[index - 1].available?
      assign_to_prev(tbl, index)
    else
      add_responder(@emergency, responder, severity_hash, type)
    end
  end

  def assign_to_prev(tbl, index)
    @emergency.responders << tbl[index - 1]
    @emergency.save
    tbl[index - 1].code = @emergency.code
  end

  def add_responder(obj, responder, severity_hash, type)
    obj.responders << responder
    obj.save!
    return unless severity_hash
    responder.emergency_code = obj.code
    severity_hash[type.downcase] -= responder.capacity
  end

  def resolved?
    @emergency.resolved_at
  end

  def save
    @emergency.save
  end

  def zero_severity?
    @emergency.fire_severity == 0 && @emergency.police_severity == 0 && @emergency.medical_severity == 0
  end

  def reset_full_response
    return @emergency.full_response = 0 if responders_names.blank? || zero_severity?
    @emergency.full_response = 0
  end

  def calc_full_response
    reset_full_response

    %w(Fire Police Medical).each do |type|
      if @emergency["#{type.downcase}_severity"] == 0
        @emergency.full_response += 1
      else
        responder_capacity = @emergency.responders.total_capacity_by(type)
        @emergency.full_response += 1 if responder_capacity >= @emergency["#{type.downcase}_severity"]
      end
    end
  end

  def assign_emergency_code
    return if responders_names.blank?

    @emergency.responders.each do |responder|
      responder.emergency_code = @emergency.code
      responder.save if responder.valid?
    end
  end

  def responders_names
    @emergency.responders.map(&:name)
  end

  def responders_types
    Responder.types
  end

  def severity_values
    hash_name = {}
    responders_types.each do |type|
      hash_name[type.downcase] = @emergency["#{type.downcase}_severity"]
    end
    hash_name
  end
end
