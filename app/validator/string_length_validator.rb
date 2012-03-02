class StringLengthValidator

  def self.validate(question, answer_value)
    return [true, nil] unless question.validate_string_length?
    return [true, nil] if answer_value.blank?

    if question.string_min
      return [false, message(question)] if answer_value.length < question.string_min
    end
    if question.string_max
      return [false, message(question)] if answer_value.length > question.string_max
    end
    return [true, nil]
  end

  private
  def self.message(question)
    StringLengthFormatter.new(question).range_text("Answer should be")
  end
end