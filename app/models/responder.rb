class Responder < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  # validates_with UnpermittedParamsValidator, fields: [:emergency_code]
  validates :name, :type, :capacity, presence: true
  validates :name, uniqueness: true
  validates :capacity, inclusion: { in: 1..5 }
end
