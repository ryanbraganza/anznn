class QuestionProblemOrganiser

  attr_accessor :problems

  def initialize
    self.problems = {}
  end

  def add_problems(question_code, baby_code, fatal_warnings, warnings)
    fatal_warnings.each { |fw| add_problem(question_code, baby_code, fw, "Error") }
    warnings.each { |w| add_problem(question_code, baby_code, w, "Warning") }
  end


  # organise the problems for display in the summary report - for each problem there's two rows
  # the first row is the question, problem type, message and count of problem records
  # the second row is a comma separated list of baby codes that have the problem
  def organised_by_question_and_message
    problem_records = problems.values.collect(&:values).flatten.sort_by { |prob| [ prob.question_code, prob.message ] }
    table = []
    table << ['Column', 'Type', 'Message', 'Number of records']
    problem_records.each do |problem|
      table << [problem.question_code, problem.type, problem.message, problem.baby_codes.size.to_s]
      table << ["", "", problem.baby_codes.join(", "), ""]
    end
    table
  end

  private

  def add_problem(question_code, baby_code, message, type)
    problems[question_code] = {} unless problems.has_key?(question_code)
    problems_for_question_code = problems[question_code]

    problems_for_question_code[message] = QuestionProblem.new(question_code, message, type) unless problems_for_question_code.has_key?(message)
    problem_object = problems_for_question_code[message]

    problem_object.add_baby_code(baby_code)
  end


end