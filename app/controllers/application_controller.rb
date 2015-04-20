require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html, :json

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
end
