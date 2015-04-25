if @emergency.valid?
  json.emergency do
    json.code @emergency.code
    json.fire_severity @emergency.fire_severity
    json.police_severity @emergency.police_severity
    json.medical_severity @emergency.medical_severity
    json.responders @responders_names ? @responders_names : []
    json.full_response "#{Emergency.full_response}/#{Emergency.total_number} emergencie(s) had sufficient responders to handle them."
    # json.full_response @emergency.full_response? ? true : false
  end
else
  json.message @emergency.errors.messages
end
