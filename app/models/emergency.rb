class Emergency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :fire_severity,
            :police_severity,
            :medical_severity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def full_responses
    full_responses_array = []
  end

  def self.total_number
    # where(resolved_at: nil).count
    count
  end

  def self.resolved_total_number
    where.not(resolved_at: nil).count
  end

  def full_response_emergencies
  end
end
