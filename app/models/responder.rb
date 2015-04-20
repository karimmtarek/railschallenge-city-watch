class Responder < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  # validates_with UnpermittedParamsValidator, fields: [:emergency_code]
  validates :name, :type, :capacity, presence: true
  validates :name, uniqueness: true
  validates :capacity, inclusion: { in: 1..5 }

  def self.filter_by_type(type)
    where(type: type)
  end

  def available?
    emergency_code.blank?
  end

  def on_duty?
    on_duty
  end

  def available_on_duty?
    available? && on_duty?
  end
end
