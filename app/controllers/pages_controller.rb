class PagesController < ApplicationController

  skip_before_filter :authenticate_user!, only: :home

  def home
    if user_signed_in?
      #TODO: this should really redirect to the responses list. Breaks lots of tests though so will leave as is for now.
      @responses = Response.all
    end
  end
end
