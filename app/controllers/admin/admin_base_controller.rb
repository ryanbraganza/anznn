class Admin::AdminBaseController < ApplicationController

  before_filter :authenticate_user!

  def index
    redirect_to admin_surveys_path
  end

end
