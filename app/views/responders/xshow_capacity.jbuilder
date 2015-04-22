json.capacity do
  @types.each do |type|
    @type_collection = Responder.filter_by_type(type)

    responders_capacity = []
    total_capacity = 0
    available_capacity = 0
    on_duty_capacity = 0
    available_on_duty_capacity = 0

    @type_collection.each do |item|
      total_capacity += item.capacity
      available_capacity += item.capacity if item.available?
      on_duty_capacity += item.capacity if item.on_duty?
      available_on_duty_capacity += item.capacity if item.available_on_duty?
    end
    responders_capacity << total_capacity << available_capacity << on_duty_capacity << available_on_duty_capacity

    json.set! type, responders_capacity
  end
end
