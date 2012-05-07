# Helper class which generates human-readable descriptions of the string length range rules
class StringLengthFormatter
  include ActionView::Helpers::NumberHelper

  attr_accessor :question

  def initialize(question)
    self.question = question
  end

  def range_text(prefix)
    min = question.string_min
    max = question.string_max
    if min && max
      if min == max
        "#{prefix} #{min} characters"
      else
        "#{prefix} between #{min} and #{max} characters"
      end
    elsif min
      "#{prefix} at least #{min} characters"
    else
      "#{prefix} a maximum of #{max} characters"
    end
  end
end