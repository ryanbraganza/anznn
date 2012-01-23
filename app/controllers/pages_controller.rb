class PagesController < ApplicationController

  skip_before_filter :authenticate_user!, only: :home

  def test
  end

  def home
    set_tab :home
  end
end
