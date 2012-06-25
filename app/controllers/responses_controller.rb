class ResponsesController < ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource

  expose(:year_of_registration_range) { ConfigurationItem.year_of_registration_range }
  expose(:surveys) { Survey.order(:name) }
  expose(:hospitals) { Hospital.hospitals_by_state }
  expose(:existing_years_of_registration) { Response.existing_years_of_registration }

  def new
  end

  def show
  end

  def submit
    @response.submit!
    redirect_to root_path, notice: "Data Entry Form for #{@response.baby_code} to #{@response.survey.name} was submitted successfully."
  end

  def create
    @response.user = current_user
    @response.hospital_id = current_user.hospital_id
    @response.submitted_status = Response::STATUS_UNSUBMITTED
    if @response.save
      redirect_to edit_response_path(@response, section: @response.survey.sections.first.id), notice: 'Data entry form created'
    else
      render :new
    end
  end

  def edit
    section_id = params[:section]
    @section = section_id.blank? ? @response.survey.sections.first : @response.survey.sections.find(section_id)

    @questions = @section.questions
    @question_id_to_answers = @response.prepare_answers_to_section_with_blanks_created(@section)
    @flag_mandatory = @response.section_started? @section
  end

  def update
    answers = params[:answers]
    answers ||= {}
    submitted_answers = answers.map { |id, val| [id.to_i, val] }

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
    @sections_to_answers = @response.sections_to_answers_with_blanks_created
  end

  def stats
    set_tab :stats, :home
  end

  def prepare_download
    set_tab :download, :home
  end

  def download
    set_tab :download, :home
    @survey_id = params[:survey_id]
    @hospital_id = params[:hospital_id]
    @year_of_registration = params[:year_of_registration]

    if @survey_id.blank?
      @errors = ["Please select a registration type"]
      render :prepare_download
    else
      generator = CsvGenerator.new(@survey_id, @hospital_id, @year_of_registration)
      if generator.empty?
        @errors = ["No data was found for your search criteria"]
        render :prepare_download
      else
        send_data generator.csv, :type => 'text/csv', :disposition => "attachment", :filename => generator.csv_filename
      end
    end
  end

  def batch_delete
    set_tab :admin, :delete_responses
    @years = Response.existing_years_of_registration
    @surveys = Survey.all
  end

  def confirm_batch_delete

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
