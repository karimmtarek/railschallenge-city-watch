class UnpermittedParamsValidator < ActiveModel::Validator
  def validate(record)
    options[:fields].each do |field|
      record.errors['found unpermitted parameter'] << field if field.present?
    end
  end
end
