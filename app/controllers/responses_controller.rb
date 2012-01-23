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
  end

  def update
    redirect_to response_path(@response), notice: 'Saved page'
  end
end
