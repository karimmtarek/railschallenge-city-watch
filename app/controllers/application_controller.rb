require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html, :json
  before_action :not_found, only: [:new, :edit, :destroy]

  protect_from_forgery with: :null_session

  private

  def unpermitted?(responder_hash, params_array)
    responder_hash.any? { |key, _value| params_array.include? key }
  end

  def unpermitted_param(responder_hash, params_array)
    params_array.each do |param|
      return param.to_s if responder_hash[param].present?
    end
  end

  def unpermitted(request_params, unpermitted_params)
    @unpermitted_param = unpermitted_param(request_params, unpermitted_params)
    render :unpermitted_parameter_error, status: :unprocessable_entity
  end

  def not_found
    render :not_found, status: :not_found
  end

  def responders_dispatch(emergency)
    return if emergency.resolved_at

    responder_types = Responder.types

    severity = severity_values(responder_types, emergency)

    dispatch_by_type(emergency, responder_types, severity, Responder)

    # responder_types.each do |type|
    #   if severity[type.downcase] > 0
    #     responders_tbl = Responder.on_duty_by(type)
    #     responders_tbl.each_with_index do |r, i|
    #       if r.capacity <= severity[type.downcase]
    #         if i == 0 || r.capacity == severity[type.downcase]
    #           emergency.responders << r
    #           emergency.save!
    #           r.emergency_code = emergency.code
    #           severity[type.downcase] -= r.capacity
    #           break if severity[type.downcase] <= 0
    #         elsif responders_tbl[i - 1].available?
    #           emergency.responders << responders_tbl[i - 1]
    #           emergency.save!
    #           responders_tbl[i - 1].code = emergency.code
    #         else
    #           emergency.responders << r
    #           emergency.save!
    #           r.emergency_code = emergency.code
    #           severity[type.downcase] -= r.capacity
    #           break if severity[type.downcase] <= 0
    #         end
    #       elsif i == responders_tbl.length - 1
    #         emergency.responders << r
    #         emergency.save!
    #       end
    #     end
    #   end
    # end

    @responders_names = emergency.responders.map(&:name) unless emergency.responders.blank?
  end

  def severity_values(types, obj)
    hash_name = {}
    types.each do |type|
      t = type.downcase
      hash_name[t] = obj["#{t}_severity"]
    end
    hash_name
  end

  def dispatch_by_type(obj, types, severity_hash, model)
    types.each do |type|
      next unless severity_hash[type.downcase] > 0
      responders_tbl = model.on_duty_by(type)
      dispatcher(obj, responders_tbl, severity_hash, type)
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
