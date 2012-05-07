# Class which organises the validation failures for a batch upload into the structures needed for generating the reports
class QuestionProblemsOrganiser

  attr_accessor :aggregated_problems
  attr_accessor :raw_problems

  def initialize
    self.aggregated_problems = {}
    self.raw_problems = []
  end

  def add_problems(question_code, baby_code, fatal_warnings, warnings, answer_value)
    fatal_warnings.each { |fw| add_problem(question_code, baby_code, fw, "Error", answer_value) }
    warnings.each { |w| add_problem(question_code, baby_code, w, "Warning", answer_value) }
  end


  # organise the aggregated problems for display in the summary report - for each problem there's two rows
  # the first row is the question, problem type, message and count of problem records
  # the second row is a comma separated list of baby codes that have the problem
  def aggregated_by_question_and_message
    problem_records = aggregated_problems.values.collect(&:values).flatten.sort_by { |prob| [ prob.question_code, prob.message ] }
    table = []
    table << ['Column', 'Type', 'Message', 'Number of records']
    problem_records.each do |problem|
      table << [problem.question_code, problem.type, problem.message, problem.baby_codes.size.to_s]
      table << ["", "", problem.baby_codes.join(", "), ""]
    end
    table
  end

  # sort the problems by baby code, column name and message
  def detailed_problems
    raw_problems.sort_by { |prob| [ prob[0], prob[1], prob[4] ] }
  end


  private

  def add_problem(question_code, baby_code, message, type, answer_value)
    # for the aggregated report, we count up unique errors by question and error message and keep track of which baby codes have those errors
    aggregated_problems[question_code] = {} unless aggregated_problems.has_key?(question_code)
    problems_for_question_code = aggregated_problems[question_code]

    problems_for_question_code[message] = QuestionProblem.new(question_code, message, type) unless problems_for_question_code.has_key?(message)
    problem_object = problems_for_question_code[message]

    problem_object.add_baby_code(baby_code)

    #for the detail report, splat out the problems into one record per baby-code / question-code / error message
    #into to an array of arrays, containing: baby-code, question-code, problem-type, value, message
    raw_problems << [baby_code, question_code, type, answer_value, message]
  end

end