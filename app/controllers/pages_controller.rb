class PagesController < ApplicationController

  skip_before_filter :authenticate_user!, only: :home

  def home
    if user_signed_in?
      @responses = current_user.super_user? ? Response.all : Response.find_all_by_hospital_id(current_user.hospital_id)
      @batch_files = BatchFile.order("created_at DESC")
    end
  end
end
