class PagesController < ApplicationController

  before_filter :authenticate_user!, except: :home

  def test
  end

  def home

  end
end
