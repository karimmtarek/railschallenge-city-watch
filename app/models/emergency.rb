class Emergency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :fire_severity,
            :police_severity,
            :medical_severity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.total_number
    # where(resolved_at: nil).count
    count
  end

  def self.resolved_total_number
    where.not(resolved_at: nil).count
  end

  def self.filter_by(type)
    # where(resolved_at: nil).
    # where("#{type.downcase}_severity >= ?", 1).
    order("#{type.downcase}_severity": :asc)
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
end
