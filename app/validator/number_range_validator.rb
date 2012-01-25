class NumberRangeValidator

  #TODO: this may end up elsewhere, just putting it here for now so we can get started on the story

  def self.validate(question, answer_value)
    return [true, nil] unless question.validate_number_range?
    return [true, nil] if answer_value.nil?

    if question.number_unknown
      return [true, nil] if answer_value == question.number_unknown
    end
    if question.number_min
      return [false, message(question)] if answer_value < question.number_min
    end
    if question.number_max
      return [false, message(question)] if answer_value > question.number_max
    end
    return [true, nil]
  end

  def self.message(question)
    NumberRangeFormatter.new(question).range_text("Answer should be")
  end

end