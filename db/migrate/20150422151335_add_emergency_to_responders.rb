class AddEmergencyToResponders < ActiveRecord::Migration
  def change
    add_reference :responders, :emergency, index: true, foreign_key: true
  end
end
