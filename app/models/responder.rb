class Responder < ActiveRecord::Base
  self.inheritance_column = :_type_disabled
  belongs_to :emergency
  validates :name, :type, :capacity, presence: true
  validates :name, uniqueness: true
  validates :capacity, inclusion: { in: 1..5 }
  before_save :remove_emergency_code

  scope :available, -> { where(emergency_code: nil) }
  scope :on_duty, -> { where(on_duty: true) }
  scope :uniq_types, -> { select(:type).distinct }
  scope :types, -> { uniq_types.map(&:type) }
  scope :types_count, -> { uniq_types.count }
  scope :filter_by, ->(type) { where(type: type).order(capacity: :asc) }
  scope :available_on_duty, -> { on_duty.available }
  scope :available_on_duty_by, ->(type) { where(type: type).on_duty.available.order(capacity: :desc) }
  scope :total_capacity_by, ->(type) { where(type: type).sum(:capacity) }
  scope :total_available_capacity_by, ->(type) { where(type: type).available.sum(:capacity) }
  scope :total_on_duty_capacity_by, ->(type) { where(type: type).on_duty.sum(:capacity) }
  scope :total_available_on_duty_capacity_by, ->(type) { where(type: type).available.on_duty.sum(:capacity) }
  scope :on_duty_capacity, -> { on_duty.sum(:capacity) }

  def available?
    emergency_code.blank?
  end

  def on_duty?
    on_duty
  end

  def available_on_duty?
    available? && on_duty?
  end

  def remove_emergency_code
    return unless emergency_id.blank?
    self.emergency_code = nil
  end
end
