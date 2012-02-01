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


    # Collect all of the answers
    answers_to_update_with_blanks = params[:answers].map { |id, val| [id.to_i, val] }

    # Remove any empty values or hashes from the list
    answers_to_update = answers_to_update_with_blanks.delete_if do |key, value|
      value.is_a?(Hash) ? !hash_values_present?(value) : value.blank?
    end

    ## Answers that have now been cleared should be removed from the DB
    #blank_answers = answers_to_update_with_blanks - answers_to_update
    #
    #Rails.logger.debug answers_to_update_with_blanks.inspect
    #Rails.logger.debug answers_to_update.inspect
    #Rails.logger.debug blank_answers.inspect

    Answer.transaction do

      # In with the new
      answers_to_update.each do |q_id, answer_value|
        answer = Answer.find_or_create_by_response_id_and_question_id(@response.id, q_id) do |answer|
          answer.answer_value = answer_value
        end
        answer.answer_value = answer_value
        answer.save!
      end

      ## Out with the old
      #old_answers = Answer.find_all_by_response_id_and_question_id(@response.id, blank_answers.keys)
      #old_answers.destroy!


    end
    redirect_after_update(params)
  end

  private

  def hash_values_present?(hash)
    hash.values.any? &:present?
  end

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
