require 'csv'
require 'csv_survey_operations.rb'
include CsvSurveyOperations
ALL_MANDATORY = 1
ALL = 2
FEW = 3

def populate_data(big=false)
  puts "Creating sample data in #{ENV["RAILS_ENV"]} environment..."
  load_password
  User.delete_all

  puts "Creating test users..."
  create_test_users
  puts "Creating surveys..."
  create_surveys
  puts "Creating responses..."
  create_responses
end

def create_responses
  Response.delete_all
  main = Survey.where(:name => 'ANZNN data form (real)').first
  followup = Survey.where(:name => 'ANZNN follow-up data form (real)').first

  hospitals = Hospital.all
  # remove the one dataprovider is linked to as we'll create those separately
  dp_hospital = User.find_by_email!('dataprovider@intersect.org.au').hospital
  hospitals.delete(dp_hospital)

  30.times { create_response(main, ALL_MANDATORY, hospitals.sample) }
  30.times { create_response(followup, ALL_MANDATORY, hospitals.sample) }
  30.times { create_response(main, ALL, hospitals.sample) }
  30.times { create_response(followup, ALL, hospitals.sample) }
  10.times { create_response(main, FEW, hospitals.sample) }
  10.times { create_response(followup, FEW, hospitals.sample) }

  create_response(main, ALL_MANDATORY, dp_hospital)
  create_response(followup, ALL_MANDATORY, dp_hospital)
  create_response(main, ALL, dp_hospital)
  create_response(followup, ALL, dp_hospital)
  create_response(main, FEW, dp_hospital)
  create_response(followup, FEW, dp_hospital)

  create_batch_files(main)
  create_batch_files(followup)
end

def create_surveys
  Response.delete_all
  BatchFile.delete_all
  Survey.delete_all
  Section.delete_all
  Question.delete_all
  QuestionOption.delete_all
  create_survey_from_lib_tasks("ANZNN data form (real)", "main_questions.csv", "main_question_options.csv", "main_cross_question_validations.csv", 'test_data/survey/real_survey')
  create_survey_from_lib_tasks("ANZNN follow-up data form (real)", "followup_questions.csv", "followup_question_options.csv", "followup_cross_question_validations.csv", 'test_data/survey/real_survey')
  create_survey_from_lib_tasks("Test data form", "test_survey_questions.csv", "test_survey_question_options.csv", "test_cross_question_validations.csv")
end

def create_survey_from_lib_tasks(name, question_file, options_file, cross_question_validations_file, dir='lib/tasks')
  path_to = ->(filename) { Rails.root.join dir, filename }
  create_survey(name, path_to[question_file], path_to[options_file], path_to[cross_question_validations_file])
end

def create_test_users
  create_user(email: "georgina@intersect.org.au", first_name: "Georgina", last_name: "Edwards")
  create_user(email: "alexb@intersect.org.au", first_name: "Alex", last_name: "Bradner")
  create_user(email: "kali@intersect.org.au", first_name: "Kali", last_name: "Waterford")
  create_user(email: "ryan@intersect.org.au", first_name: "Ryan", last_name: "Braganza")
  create_user(email: "dataprovider@intersect.org.au", first_name: "Data", last_name: "Provider")
  create_user(email: "supervisor@intersect.org.au", first_name: "Data", last_name: "Supervisor")
  create_user(email: "dataprovider2@intersect.org.au", first_name: "Data", last_name: "Provider2")
  create_user(email: "supervisor2@intersect.org.au", first_name: "Data", last_name: "Supervisor2")
  create_unapproved_user(email: "unapproved1@intersect.org.au", first_name: "Unapproved", last_name: "One")
  create_unapproved_user(email: "unapproved2@intersect.org.au", first_name: "Unapproved", last_name: "Two")
  set_role("georgina@intersect.org.au", "Administrator")
  set_role("alexb@intersect.org.au", "Administrator")
  set_role("kali@intersect.org.au", "Administrator")
  set_role("ryan@intersect.org.au", "Administrator")
  set_role("dataprovider@intersect.org.au", "Data Provider", Hospital.first.name)
  set_role("supervisor@intersect.org.au", "Data Provider Supervisor", Hospital.first.name)
  set_role("dataprovider2@intersect.org.au", "Data Provider", Hospital.last.name)
  set_role("supervisor2@intersect.org.au", "Data Provider Supervisor", Hospital.last.name)
end

def set_role(email, role, hospital_name=nil)
  user = User.find_by_email(email)
  role = Role.find_by_name(role)
  hospital = Hospital.find_by_name(hospital_name) unless hospital_name.nil?
  user.role = role
  user.hospital = hospital
  user.save!
end

def create_user(attrs)
  u = User.new(attrs.merge(password: @password))
  u.activate
  u.save!
end

def create_unapproved_user(attrs)
  u = User.create!(attrs.merge(password: @password))
  u.save!
end

def load_password
  password_file = "#{Rails.root}/tmp/env_config/sample_password.yml"
  if File.exists? password_file
    puts "Using sample user password from #{password_file}"
    password = YAML::load_file(password_file)
    @password = password[:password]
    return
  end

  if Rails.env.development?
    puts "#{password_file} missing.\n" +
             "Set sample user password:"
    input = STDIN.gets.chomp
    buffer = Hash[password: input]
    Dir.mkdir("#{Rails.root}/tmp", 0755) unless Dir.exists?("#{Rails.root}/tmp")
    Dir.mkdir("#{Rails.root}/tmp/env_config", 0755) unless Dir.exists?("#{Rails.root}/tmp/env_config")
    File.open(password_file, 'w') do |out|
      YAML::dump(buffer, out)
    end
    @password = input
  else
    raise "No sample password file provided, and it is required for any environment that isn't development\n" +
              "Use capistrano's deploy:populate task to generate one"
  end

end

def create_response(survey, profile, hospital)
  status = Response::STATUS_UNSUBMITTED
  year_of_reg = 2007
  base_date = random_date_in(2007)
  prefix = case profile
             when ALL
               "big"
             when ALL_MANDATORY
               "med"
             when FEW
               "small"
           end
  response = Response.create!(hospital: hospital,
                              submitted_status: status,
                              baby_code: "#{prefix}-#{hospital.abbrev}-#{rand(10000000)}",
                              survey: survey,
                              year_of_registration: year_of_reg,
                              user: User.all.sample)


  questions = case profile
                when ALL
                  survey.questions
                when ALL_MANDATORY
                  survey.questions.where(:mandatory => true)
                when FEW
                  survey.questions.all[1..15]
              end
  questions.each do |question|
    answer = response.answers.build(question_id: question.id)
    answer_value = case question.question_type
                     when Question::TYPE_CHOICE
                       random_choice(question)
                     when Question::TYPE_DATE
                       random_date(base_date)
                     when Question::TYPE_DECIMAL
                       random_number(question)
                     when Question::TYPE_INTEGER
                       random_number(question)
                     when Question::TYPE_TEXT
                       random_text(question)
                     when Question::TYPE_TIME
                       random_time
                   end
    answer.answer_value = answer_value
    answer.save!
  end
end

def create_batch_files(survey)
  create_batch_file(survey, 5)
  create_batch_file(survey, 10)
  create_batch_file(survey, 50)
end

def create_batch_file(survey, count_of_rows)
  responses = Response.where(survey_id: survey.id).all
  responses_to_use = responses.sample(count_of_rows)


end

def random_date_in(year)
  days = rand(364)
  Date.new(year, 1, 1) + days.days
end

def random_choice(question)
  question.question_options.all.sample.option_value
end

def random_date(base_date)
  base_date + rand(-30..30).days
end

def random_number(question)
  end_of_range = question.number_max ? question.number_max : 500
  start_of_range = question.number_min ? question.number_min : -500
  rand(start_of_range..end_of_range)
end

def random_text(question)
  rand(-999999..999999).to_s
end

def random_time
  "#{rand(0..23)}:#{rand(0..59)}"
end


