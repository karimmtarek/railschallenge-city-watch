class Responder < ActiveRecord::Base
  self.inheritance_column = :_type_disabled
  belongs_to :emergency
  # validates_with UnpermittedParamsValidator, fields: [:emergency_code]
  validates :name, :type, :capacity, presence: true
  validates :name, uniqueness: true
  validates :capacity, inclusion: { in: 1..5 }
  before_save :remove_emergency_code

  def self.types
    select(:type).distinct.map(&:type)
  end

  def self.types_count
    select(:type).distinct.count
  end

  def self.filter_by(type)
    # where(type: type)
    where(type: type).order(capacity: :asc)
  end

  def available?
    emergency_code.blank?
  end

  def self.on_duty
    where(on_duty: true).where(emergency_code: nil)
  end

  def self.on_duty_by(type)
    where(type: type).where(on_duty: true).where(emergency_code: nil).order(capacity: :desc)
  end

  def on_duty?
    on_duty
  end

  def available_on_duty?
    available? && on_duty?
  end

  def self.total_capacity_by(type)
    where(type: type).sum(:capacity)
  end

  def self.total_available_capacity_by(type)
    where(type: type).where(emergency_code: nil).sum(:capacity)
  end

  def self.total_on_duty_capacity_by(type)
    where(type: type).where(on_duty: true).sum(:capacity)
  end

  def self.total_available_on_duty_capacity_by(type)
    where(type: type).where(emergency_code: nil).where(on_duty: true).sum(:capacity)
  end

  def self.on_duty_capacity
    where(on_duty: true).sum(:capacity)
  end

  def remove_emergency_code
    return unless emergency_id.blank?
    self.emergency_code = nil
  end
end
