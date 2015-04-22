json.capacity do
  @types.each_with_index do |type, index|
    json.set! type, @responders_capacity[index]
  end
end
