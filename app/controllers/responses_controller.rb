class ResponsesController < ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource

  expose(:year_of_registration_range) { ConfigurationItem.year_of_registration_range }
  expose(:surveys) { SURVEYS.values }
  expose(:hospitals) { Hospital.hospitals_by_state }
  expose(:existing_years_of_registration) { Response.existing_years_of_registration }

  def new
  end

  def show
    #WARNING: this is a performance enhancing hack to get around the fact that reverse associations are not loaded as one would expect - don't change it
    set_response_value_on_answers(@response)
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
      redirect_to edit_response_path(@response, section: @response.survey.first_section.id), notice: 'Data entry form created'
    else
      render :new
    end
  end

  def edit
    section_id = params[:section]
    @section = section_id.blank? ? @response.survey.first_section : @response.survey.section_with_id(section_id)

    @questions = @section.questions
    @flag_mandatory = @response.section_started? @section
    @question_id_to_answers = @response.prepare_answers_to_section_with_blanks_created(@section)
    @group_info = calculate_group_info(@section, @questions)
  end

  def update
    answers = params[:answers]
    answers ||= {}
    submitted_answers = answers.map { |id, val| [id.to_i, val] }
     #WARNING: this is a performance enhancing hack to get around the fact that reverse associations are not loaded as one would expect - don't change it
    set_response_value_on_answers(@response)

    Answer.transaction do
      submitted_answers.each do |q_id, answer_value|
        answer = @response.get_answer_to(q_id)
        if blank_answer?(answer_value)
          answer.destroy if answer
        else
          answer = @response.answers.build(question_id: q_id) unless answer
          answer.answer_value = answer_value
          answer.save!
        end
      end
    end
    # reload and trigger a save so that status is recomputed afresh - DONT REMOVE THIS
    @response.reload
     #WARNING: this is a performance enhancing hack to get around the fact that reverse associations are not loaded as one would expect - don't change it
    set_response_value_on_answers(@response)
    @response.save!

    redirect_after_update(params)
  end

  def review_answers
    #WARNING: this is a performance enhancing hack to get around the fact that reverse associations are not loaded as one would expect - don't change it
    set_response_value_on_answers(@response)

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
    set_tab :delete_responses, :admin_navigation
  end

  def confirm_batch_delete
    @year = params[:year_of_registration] || ""
    @registration_type_id = params[:registration_type] || ""

    @errors = validate_batch_delete_form(@year, @registration_type_id)
    if @errors.empty?
      @registration_type = SURVEYS[@registration_type_id.to_i]
      @count = Response.count_per_survey_and_year_of_registration(@registration_type_id, @year)
    else
      batch_delete
      render :batch_delete
    end
  end

  def perform_batch_delete
    @year = params[:year_of_registration] || ""
    @registration_type_id = params[:registration_type] || ""

    @errors = validate_batch_delete_form(@year, @registration_type_id)
    if @errors.empty?
      Response.delete_by_survey_and_year_of_registration(@registration_type_id, @year)
      redirect_to batch_delete_responses_path, :notice => 'The records were deleted'
    else
      redirect_to batch_delete_responses_path
    end
  end

  private

  def validate_batch_delete_form(year, survey_id)
    errors = []
    errors << "Please select a year of registration" if year.blank?
    errors << "Please select a registration type" if survey_id.blank?
    errors
  end

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

  def calculate_group_info(section, questions_in_section)
    group_names = questions_in_section.collect(&:multi_name).uniq.compact
    result = {}
    group_names.each do |g|
      questions_for_group = questions_in_section.select { |q| q.multi_name == g }
      result[g] = GroupedQuestionHandler.new(g, questions_for_group, @question_id_to_answers)
    end
    result
  end

  def set_response_value_on_answers(response)
    response.answers.each { |a| a.response = response }
  end

end
