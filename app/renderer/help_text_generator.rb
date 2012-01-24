class HelpTextGenerator
  include ActionView::Helpers::NumberHelper
  #TODO: figure out where this really belongs
  attr_accessor :question

  def initialize(question)
    self.question = question
  end

  def help_text
    if question.type_text?
      format_hint_for_text_type
    elsif question.type_integer?
      format_hint_for_number_type("Number")
    elsif question.type_decimal?
      format_hint_for_number_type("Decimal number")
    else
      nil
    end

  end

  private

  def format_hint_for_text_type
    if question.validate_string_length?
      min = question.string_min
      max = question.string_max
      if min && max
        "Text between #{min} and #{max} characters long"
      elsif min
        "Text at least #{min} characters long"
      else
        "Text up to #{max} characters long"
      end
    else
      "Text"
    end
  end

  def format_hint_for_number_type(prefix)
    if question.validate_number_range?
      min = question.number_min
      max = question.number_max
      if min && max
        base = "#{prefix} between #{format_number(min)} and #{format_number(max)}"
      elsif min
        base = "#{prefix} at least #{format_number(min)}"
      else
        base = "#{prefix} up to #{format_number(max)}"
      end
      question.number_unknown ? "#{base} or #{question.number_unknown} for unknown" : base
    else
      prefix
    end
  end

  def format_number(decimal)
    number_with_precision(decimal, :precision => 10, :strip_insignificant_zeros => true)
  end
end