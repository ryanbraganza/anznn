require 'csv_survey_operations.rb'
include CsvSurveyOperations

def confirm?
  print "Are you sure? Type yes to continue: "
  input = STDIN.gets.chomp

  input == 'yes'
end

begin
  desc "Import a new questionnaire"
  task :import_questionnaire, [:name, :question_file, :options_file, :cross_question_validations_file]  => :environment do |task, args|
    name = args.name.try :strip
    question_file = args.question_file.try :strip
    options_file = args.options_file.try :strip
    cross_question_validations_file = args.cross_question_validations_file.try :strip

    errors = []
    errors << "Please provide a name" unless name
    errors << "Please provide a question file" unless question_file
    errors << "Please provide a options file" unless options_file
    errors << "Please provide a cross question validations file" unless cross_question_validations_file

    if errors.any?
      puts errors.join("\n")
      puts %q{e.g. rake "import_questionnaire[My Questionnaire Name, question_file.csv, options_file.csv, cross_question_validations.csv]"}
    else
      puts <<-EOS
        importing
        survey: #{name}
        questions: #{question_file}
        options: #{options_file}
        cross-question validations: #{cross_question_validations_file}
      EOS
      if confirm?
        create_survey(name, question_file, options_file, cross_question_validations_file)
      else
        puts "Aborted"
      end
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end
