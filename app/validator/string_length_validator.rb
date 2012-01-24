class StringLengthValidator
  #TODO: this may end up elsewhere, just putting it here for now so we can get started on the story
  def self.validate(question, answer_value)
    return true unless question.validate_string_length?
    return true if answer_value.blank?

    if question.string_min
      return false if answer_value.length < question.string_min
    end
    if question.string_max
      return false if answer_value.length > question.string_max
    end
    return true
  end

  
end