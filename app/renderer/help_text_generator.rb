# Helper class which generates the help text for a question based on the properties of the question
class HelpTextGenerator
  attr_accessor :question

  def initialize(question)
    self.question = question
  end

  def help_text
    if question.type_text?
      help_text_for_text_type
    elsif question.type_integer?
      help_text_for_number_type("Number")
    elsif question.type_decimal?
      help_text_for_number_type("Decimal number")
    else
      nil
    end
  end

  private

  def help_text_for_text_type
    if question.validate_string_length?
      StringLengthFormatter.new(question).range_text("Text")
    else
      "Text"
    end
  end

  def help_text_for_number_type(prefix)
    if question.validate_number_range?
      NumberRangeFormatter.new(question).range_text(prefix)
    else
      prefix
    end
  end
end