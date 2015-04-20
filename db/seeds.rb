Responder.delete_all

types = %w(Fire Police Medical)

1.upto(rand(5..10)) do
  types.each do |type|
    Responder.create!(
      type: type,
      name: "#{type}-name-#{rand(1..5000)}",
      capacity: rand(1..5)
    )
  end
end
