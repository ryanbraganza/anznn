class PagesController < ApplicationController

  skip_before_filter :authenticate_user!, only: :home
  expose(:surveys) { Survey.order(:name) }
  expose(:hospitals) { Hospital.hospitals_by_state }

  def home
    if user_signed_in?
      @responses = Response.accessible_by(current_ability).order("baby_code")
      @batch_files = BatchFile.accessible_by(current_ability).order("created_at DESC")
    end
  end
end
