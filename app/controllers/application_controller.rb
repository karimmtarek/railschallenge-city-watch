require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html, :json
  before_action :not_found, only: [:new, :edit, :destroy]

  protect_from_forgery with: :null_session

  private

  def unpermitted_param?(responder_hash, params_array)
    responder_hash.any? { |key, _value| params_array.include? key }
  end

  def unpermitted_param(responder_hash, params_array)
    params_array.each do |param|
      return param.to_s if responder_hash[param].present?
    end
  end

  def not_found
    render :not_found, status: :not_found
  end

  def responders_dispatch(emergency)
    return if emergency.resolved_at

    responder_types = Responder.types

    severity = {}
    responder_types.each do |type|
      t = type.downcase
      severity[t] = emergency["#{t}_severity"]
    end

    responder_types.each do |type|
      if severity[type.downcase] > 0
        responders_tbl = Responder.on_duty_by(type)
        responders_tbl.each_with_index do |r, i|
          if r.capacity <= severity[type.downcase]
            if i == 0 || r.capacity == severity[type.downcase]
              emergency.responders << r
              emergency.save!
              r.emergency_code = emergency.code
              severity[type.downcase] -= r.capacity
              break if severity[type.downcase] <= 0
            elsif responders_tbl[i - 1].available?
              emergency.responders << responders_tbl[i - 1]
              emergency.save!
              responders_tbl[i - 1].code = emergency.code
            else
              emergency.responders << r
              emergency.save!
              r.emergency_code = emergency.code
              severity[type.downcase] -= r.capacity
              break if severity[type.downcase] <= 0
            end
          elsif i == responders_tbl.length - 1
            emergency.responders << r
            emergency.save!
          end
        end
      end
    end

    # emergency.calc_full_response
    # binding.pry
    @responders_names = emergency.responders.map(&:name) unless emergency.responders.blank?
  end
end
