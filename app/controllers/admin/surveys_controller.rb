class Admin::SurveysController < Admin::AdminBaseController

  load_and_authorize_resource
  set_tab :surveys, :admin_navigation

  def show

  end

  def index

  end
end
