class QuestionProblemDetailOrganiser

  attr_accessor :problems

  def initialize
    self.problems = []
  end

  def add_problems(question_code, baby_code, fatal_warnings, warnings, answer_value)
    #splat out the problems in to an array of arrays, containing: baby-code, question-code, problem-type, value, message
    fatal_warnings.each { |fw| add_problem(question_code, baby_code, fw, "Error", answer_value) }
    warnings.each { |w| add_problem(question_code, baby_code, w, "Warning", answer_value) }
  end

  # sort the problems by baby code, column name and message
  def sorted_problems
    problems.sort_by { |prob| [ prob[0], prob[1], prob[4] ] }
  end

  private

  def add_problem(question_code, baby_code, message, type, answer_value)
    problems << [baby_code, question_code, type, answer_value, message]
  end


end