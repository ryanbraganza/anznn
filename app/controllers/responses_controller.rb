class ResponsesController < ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource

  def new
  end

  def create
    @response.survey = Survey.first  # TODO support multiple surveys
    @response.user = current_user
    if @response.save
      redirect_to response_path(@response), notice: 'Survey created'
    else
      render :new
    end
  end

  def show
    @questions = @response.survey.sections.first.questions
    answers = @response.answers
    @question_id_to_answers = answers.reduce({}){|hash, answer| hash[answer.question_id] = answer.text_answer; hash}
  end

  def update
    answers_to_update = params[:answers].map{|id, val| [id.to_i, val]}
    Answer.transaction do
      answers_to_update.each do |q_id, answer_value|
        answer = Answer.find_or_create_by_response_id_and_question_id(@response.id, q_id)
        answer.text_answer = answer_value
        answer.save!
      end
    end
    redirect_to response_path(@response), notice: 'Saved page'
  end
end
