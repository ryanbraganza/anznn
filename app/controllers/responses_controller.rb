class ResponsesController < ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource

  def new
  end

  def create
    @response.survey = Survey.first # TODO support multiple surveys
    @response.user = current_user
    if @response.save
      redirect_to edit_response_path(@response), notice: 'Survey created'
    else
      render :new
    end
  end

  def edit
    @questions = []
    @response.survey.sections.each do |sect|
      sect.questions.each do |qn|
        @questions << qn
      end
    end
    @response.compute_warnings
    @question_id_to_answers = @response.question_id_to_answers
  end

  def update
    answers_to_update = params[:answers].map { |id, val| [id.to_i, val] }
    Answer.transaction do

      answers_to_update.each do |q_id, answer_value|
        answer = Answer.find_or_create_by_response_id_and_question_id(@response.id, q_id)
        answer.sanitise_input(answer_value, Question.find(q_id).question_type)
        answer.save!
      end
    end
    redirect_to edit_response_path(@response), notice: 'Saved page'
  end
end
