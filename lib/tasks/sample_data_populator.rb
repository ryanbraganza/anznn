require 'csv'
require 'csv_survey_operations.rb'
include CsvSurveyOperations

def populate_data
  puts "Creating sample data in #{ENV["RAILS_ENV"]} environment..."
  load_password
  User.delete_all

  puts "Creating hospitals..."
  create_hospitals
  puts "Creating test users..."
  create_test_users
  puts "Creating surveys..."
  create_surveys
  puts "Creating sample responses..."
  create_responses
end

def create_responses
  Response.delete_all
  hospitals = Hospital.all
  hospital_count = hospitals.size
  survey1 = Survey.first
  survey2 = Survey.all[1]

  102.times do |i|
    status = (i % 2 == 0) ? Response::STATUS_UNSUBMITTED : Response::STATUS_SUBMITTED
    survey = (i % 3 == 0) ? survey2 : survey1
    year_of_reg = 2000 + (i % 4)
    hospital = hospitals[i % 10]
    Factory(:response,
            hospital: hospital,
            submitted_status: status,
            baby_code: "Baby-#{hospital.abbrev}-#{i}",
            survey: survey,
            year_of_registration: year_of_reg)
  end
end

def create_hospitals
  Hospital.delete_all

  hospitals = read_hashes_from_csv(Rails.root.join("lib/tasks", "hospitals.csv"))
  hospitals.each do |hash|
    Hospital.create!(hash)
  end
end


def create_surveys
  Response.delete_all
  BatchFile.delete_all
  Survey.delete_all
  Section.delete_all
  Question.delete_all
  QuestionOption.delete_all
  create_survey_from_lib_tasks("Main Survey", "main_survey_questions.csv", "main_survey_question_options.csv", "main_cross_question_validations.csv")
  create_survey_from_lib_tasks("Followup Survey", "followup_survey_questions.csv", "followup_survey_question_options.csv", "followup_cross_question_validations.csv")
  create_survey_from_lib_tasks("Test Survey", "test_survey_questions.csv", "test_survey_question_options.csv", "test_cross_question_validations.csv")
end

def create_survey_from_lib_tasks(name, question_file, options_file, cross_question_validations_file)
  path_to = ->(filename){Rails.root.join 'lib/tasks', filename}
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


