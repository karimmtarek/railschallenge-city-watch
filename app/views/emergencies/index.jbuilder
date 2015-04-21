json.full_responses @full_responses
json.emergencies do
  json.array! @emergencies.each do |emergency|
    json.code emergency.code
    json.fire_severity emergency.fire_severity
    json.police_severity emergency.police_severity
    json.medical_severity emergency.medical_severity
    json.resolved_at emergency.resolved_at
  end
end
