if @emergency.valid?
  json.emergency do
    json.code @emergency.code
    json.fire_severity @emergency.fire_severity
    json.police_severity @emergency.police_severity
    json.medical_severity @emergency.medical_severity
    json.responders @responders_names ? @responders_names : []
    json.full_response "Full response is: #{@emergency.full_response?}"
  end
else
  json.message @emergency.errors.messages
end
