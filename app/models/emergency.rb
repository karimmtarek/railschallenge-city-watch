class Emergency < ActiveRecord::Base
  has_many :responders
  validates :code, presence: true, uniqueness: true
  validates :fire_severity,
            :police_severity,
            :medical_severity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  before_save :assign_emergency_code

  scope :total_number, -> { count }
  scope :resolved_total_number, -> { where.not(resolved_at: nil).count }
  scope :full_response, -> { where(full_response: 3).count }
  scope :filter_by, ->(type) { order("#{type.downcase}_severity": :asc) }

  def full_response?
    full_response == 3
  end

  def severity(type)
    self["#{type.downcase}_severity"]
  end

  def resolved?
    resolved_at.present?
  end

  def not_resolved?
    resolved_at.blank?
  end

  def not_resolved_by_type?(type)
    resolved_at.blank? && self["#{type.downcase}_severity"] > 0
  end

  def calc_full_response
    return self.full_response = 0 if responders.blank? || zero_severity?

    self.full_response = 0
    %w(Fire Police Medical).each do |type|
      if self["#{type.downcase}_severity"] == 0
        self.full_response += 1
      else
        responder_capacity = responders.where(type: type).sum(:capacity)
        self.full_response += 1 if responder_capacity >= self["#{type.downcase}_severity"]
      end
    end
    # self.save
  end

  def zero_severity?
    fire_severity == 0 && police_severity == 0 && medical_severity == 0
  end

  def assign_emergency_code
    return if responders.blank?

    responders.each do |r|
      r.emergency_code = code
      r.save
    end
  end

  def release_responders
    return if responders.blank?

    responders.each do |r|
      r.emergency_code = nil
      r.save
    end
    self.responders = []
  end
end
