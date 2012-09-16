SURVEYS = {}
QUESTIONS = {}

class StaticModelPreloader
  def self.load
    SURVEYS.clear
    Survey.order(:name).all.each do |survey|
      SURVEYS[survey.id] = survey
    end

    QUESTIONS.clear
    Question.includes(:cross_question_validations, :question_options).all.each do |question|
      QUESTIONS[question.id] = question
    end
  end
end

StaticModelPreloader.load unless ENV['SKIP_PRELOAD_MODELS'] == 'skip'
