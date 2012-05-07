# Helper class which generates human-readable descriptions of the range rules
class NumberRangeFormatter

  include ActionView::Helpers::NumberHelper

  attr_accessor :question

  def initialize(question)
    self.question = question
  end

  def range_text(prefix)
    if question.validate_number_range?
      min = question.number_min
      max = question.number_max
      if min && max
        base = "#{prefix} between #{format_number(min)} and #{format_number(max)}"
      elsif min
        base = "#{prefix} at least #{format_number(min)}"
      else
        base = "#{prefix} a maximum of #{format_number(max)}"
      end
      question.number_unknown ? "#{base} or #{question.number_unknown} for unknown" : base
    else
      nil
    end
  end

  def format_number(decimal)
    number_with_precision(decimal, :precision => 10, :strip_insignificant_zeros => true)
  end

end