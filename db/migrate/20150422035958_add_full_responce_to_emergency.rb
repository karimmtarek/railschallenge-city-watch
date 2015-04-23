class AddFullResponceToEmergency < ActiveRecord::Migration
  def change
    add_column :emergencies, :full_response, :integer, default: 0
  end
end
