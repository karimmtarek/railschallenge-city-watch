if @emergency.valid?
  json.emergency do
    json.code @emergency.code
    json.fire_severity @emergency.fire_severity
    json.police_severity @emergency.police_severity
    json.medical_severity @emergency.medical_severity
  end
else
  json.message @emergency.errors.messages
end
