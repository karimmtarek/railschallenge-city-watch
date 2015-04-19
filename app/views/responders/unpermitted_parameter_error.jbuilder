if @unpermitted_param.class == Array
  json.message 'found unpermitted parameter: ' +  @unpermitted_param.join(', ')
else
  json.message 'found unpermitted parameter: ' +  @unpermitted_param
end
