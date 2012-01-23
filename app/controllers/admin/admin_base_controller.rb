class Admin::AdminBaseController < ApplicationController

  before_filter :authenticate_user!
  set_tab :admin

  def index
    redirect_to admin_surveys_path
  end

end
