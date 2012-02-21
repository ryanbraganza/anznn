class PagesController < ApplicationController

  skip_before_filter :authenticate_user!, only: :home

  def home
    if user_signed_in?
      @responses = Response.all
      @batch_files = BatchFile.order("created_at DESC")
    end
  end
end
