class PagesController < ApplicationController

  skip_before_filter :authenticate_user!, only: :home

  def home
    if user_signed_in?
      set_tab :responses, :home
      @responses = Response.accessible_by(current_ability).unsubmitted.order("baby_code")
    end
  end
end
