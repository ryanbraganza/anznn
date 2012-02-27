class PagesController < ApplicationController

  skip_before_filter :authenticate_user!, only: :home

  def home
    if user_signed_in?
      @responses = Response.accessible_by(current_ability)
      @batch_files = BatchFile.accessible_by(current_ability).order("created_at DESC")
    end
  end
end
