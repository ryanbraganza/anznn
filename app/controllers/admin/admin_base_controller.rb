class Admin::AdminBaseController < ApplicationController

  before_filter :authenticate_user!

end
