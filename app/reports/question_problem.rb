# Utility class for storing the details of a validation failure for a batch upload
class QuestionProblem

  attr_accessor :question_code
  attr_accessor :message
  attr_accessor :baby_codes
  attr_accessor :type

  def initialize(question_code, message, type)
    self.question_code = question_code
    self.message = message
    self.type = type
    self.baby_codes = []
  end

  def add_baby_code(code)
    baby_codes << code
  end

end