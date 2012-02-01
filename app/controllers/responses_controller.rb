class ResponsesController < ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource

  set_tab :responses

  def index;
  end

  def new;
  end

  def create
    @response.user = current_user
    if @response.save
      redirect_to edit_response_path(@response, section: @response.survey.sections.first.id), notice: 'Survey created'
    else
      render :new
    end
  end

  def edit
    section_id = params[:section]
    @section = section_id.blank? ? @response.survey.sections.first : @response.survey.sections.find(section_id)

    @questions = @section.questions

    #@response.compute_warnings
    @question_id_to_answers = @response.question_id_to_answers
  end

  def update

    answers_to_update = params[:answers].map { |id, val| [id.to_i, val] }
    Answer.transaction do

      answers_to_update.each do |q_id, answer_value|
        Answer.find_or_create_by_response_id_and_question_id(@response.id, q_id) do |answer|
          answer.answer_value = answer_value
        end
      end
    end
    redirect_after_update(params)
  end

  private

  def redirect_after_update(params)
    clicked = params[:commit]

    if clicked =~ /Save and return to home/
      redirect_to root_path
    else
      go_to_section = params[:go_to_section]
      if clicked =~ /Save and go to next section/
        go_to_section = @response.survey.section_id_after(go_to_section.to_i)
      end
      redirect_to edit_response_path(@response, section: go_to_section), notice: 'Your answers have been saved'
    end
  end
end
