class ResponsesController < ApplicationController
  load_and_authorize_resource

  def new
  end

  def create
    if @response.save
      redirect_to response_path(@response)
    else
      render :new
    end
  end

  def show
  end
end
