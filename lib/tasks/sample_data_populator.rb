require 'csv'

def populate_data
  load_password

  User.delete_all
  create_test_users

  create_surveys
end

def create_surveys
  Response.delete_all
  Survey.delete_all
  Section.delete_all
  Question.delete_all
  QuestionOption.delete_all
  create_survey("Main Survey", "main_survey_questions.csv", "main_survey_question_options.csv", "main_cross_question_validations.csv")
  create_survey("Followup Survey", "followup_survey_questions.csv", "followup_survey_question_options.csv", "followup_cross_question_validations.csv")

end

def create_survey(name, question_file, options_file, cross_question_validations_file)
  include CsvSurveyOperations

  survey = Survey.create!(name: name)

  questions = read_hashes_from_csv(Rails.root.join("lib/tasks", question_file))
  question_options = read_hashes_from_csv(Rails.root.join("lib/tasks", options_file))
  cqv_hashes = read_hashes_from_csv(Rails.root.join("lib/tasks", cross_question_validations_file))
 
  import_questions(survey, questions)
  import_question_options(survey, question_options)
  import_cross_question_validations(survey, cqv_hashes)
end

def create_test_users
  create_user(email: "sean@intersect.org.au", first_name: "Sean", last_name: "McCarthy")
  create_user(email: "georgina@intersect.org.au", first_name: "Georgina", last_name: "Edwards")
  create_user(email: "veronica@intersect.org.au", first_name: "Veronica", last_name: "Luke")
  create_user(email: "alexb@intersect.org.au", first_name: "Alex", last_name: "Bradner")
  create_user(email: "kali@intersect.org.au", first_name: "Kali", last_name: "Waterford")
  create_user(email: "diego@intersect.org.au", first_name: "Diego", last_name: "Alonso de Marcos")
  create_user(email: "shuqian@intersect.org.au", first_name: "Shuqian", last_name: "Hon")
  create_user(email: "dataprovider@intersect.org.au", first_name: "Data", last_name: "Provider")
  create_unapproved_user(email: "unapproved1@intersect.org.au", first_name: "Unapproved", last_name: "One")
  create_unapproved_user(email: "unapproved2@intersect.org.au", first_name: "Unapproved", last_name: "Two")
  set_role("sean@intersect.org.au", "Administrator")
  set_role("georgina@intersect.org.au", "Administrator")
  set_role("veronica@intersect.org.au", "Administrator")
  set_role("alexb@intersect.org.au", "Administrator")
  set_role("kali@intersect.org.au", "Administrator")
  set_role("diego@intersect.org.au", "Administrator")
  set_role("shuqian@intersect.org.au", "Administrator")
  set_role("dataprovider@intersect.org.au", "Data Provider")

end

def set_role(email, role)
  user = User.where(email: email).first
  role = Role.where(name: role).first
  user.role = role
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


