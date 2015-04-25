class RespondersDispatcher
  attr_reader :emergency

  def initialize(emergency)
    @e = emergency
  end

  def dispatch
    return if resolved?

    dispatch_by_type
    calc_full_response
    assign_emergency_code
    save
  end

  def resolved?
    @e.resolved_at
  end

  def save
    @e.save
  end

  def zero_severity?
    @e.fire_severity == 0 && @e.police_severity == 0 && @e.medical_severity == 0
  end

  def reset_full_response
    return @e.full_response = 0 if responders_names.blank? || zero_severity?
    @e.full_response = 0
  end

  def calc_full_response
    reset_full_response

    %w(Fire Police Medical).each do |type|
      if @e["#{type.downcase}_severity"] == 0
        @e.full_response += 1
      else
        responder_capacity = @e.responders.total_capacity_by(type)
        @e.full_response += 1 if responder_capacity >= @e["#{type.downcase}_severity"]
      end
    end
  end

  def assign_emergency_code
    return if responders_names.blank?

    @e.responders.each do |responder|
      responder.emergency_code = @e.code
      responder.save if responder.valid?
    end
  end

  def responders_names
    @e.responders.map(&:name)
  end

  def responders_types
    Responder.types
  end

  def severity_values
    hash_name = {}
    responders_types.each do |type|
      t = type.downcase
      hash_name[t] = @e["#{t}_severity"]
    end
    hash_name
  end

  def dispatch_by_type
    responders_types.each do |type|
      next unless severity_values[type.downcase] > 0
      responders_tbl = Responder.available_on_duty_by(type)
      dispatcher(@e, responders_tbl, severity_values, type)
    end
  end

  def dispatcher(obj, tbl, severity_hash, type)
    tbl.each_with_index do |responder, index|
      if responder.capacity <= severity_hash[type.downcase]
        if index == 0 || responder.capacity == severity_hash[type.downcase]
          add_responder(obj, responder, severity_hash, type)
          break if severity_hash[type.downcase] <= 0
        elsif tbl[index - 1].available?
          obj.responders << tbl[index - 1]
          obj.save!
          tbl[index - 1].code = obj.code
        else
          add_responder(obj, responder, severity_hash, type)
          break if severity_hash[type.downcase] <= 0
        end
      elsif index == tbl.length - 1
        add_responder(obj, responder, nil, nil)
      end
    end
  end

  def add_responder(obj, responder, severity_hash, type)
    obj.responders << responder
    obj.save!
    return unless severity_hash
    responder.emergency_code = obj.code
    severity_hash[type.downcase] -= responder.capacity
  end
end
