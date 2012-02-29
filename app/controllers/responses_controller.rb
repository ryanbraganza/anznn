class ResponsesController < ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource

  def new
  end

  def show
  end

  def submit
    @response.submit!
    redirect_to root_path, notice: "Response for #{@response.baby_code} to #{@response.survey.name} was submitted successfully."
  end

  def create
    @response.user = current_user
    @response.hospital_id = current_user.hospital_id
    @response.submitted_status = Response::STATUS_UNSUBMITTED
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
    @question_id_to_answers = @response.prepare_answers_to_section(@section)
    @flag_mandatory = @response.section_started? @section
  end

  def update
    submitted_answers = params[:answers].map { |id, val| [id.to_i, val] }

    Answer.transaction do
      submitted_answers.each do |q_id, answer_value|
        answer = Answer.find_by_response_id_and_question_id(@response.id, q_id)
        if blank_answer?(answer_value)
          answer.destroy if answer
        else
          answer = @response.answers.build(question_id: q_id) unless answer
          answer.answer_value = answer_value
          answer.save!
        end
      end
    end

    redirect_after_update(params)
  end

  def review_answers
    @sections_to_answers = @response.sections_to_answers
  end

  private

  def blank_answer?(value)
    value.is_a?(Hash) ? !hash_values_present?(value) : value.blank?
  end

  def hash_values_present?(hash)
    hash.values.any? &:present?
  end

  def redirect_after_update(params)
    clicked = params[:commit]

    go_to_section = params[:go_to_section]

    if clicked =~ /^Save and return to summary page/
      go_to_section = 'summary'
    elsif clicked =~ /^Save and go to next section/
      go_to_section = @response.survey.section_id_after(go_to_section.to_i)
    end

    if go_to_section == "summary"
      redirect_to @response, notice: 'Your answers have been saved'
    else
      redirect_to edit_response_path(@response, section: go_to_section), notice: 'Your answers have been saved'
    end
  end
end
