class StaticPagesController < ApplicationController
  before_action :signout_required, only: [ :welcome ]

  def help
  end

  def settings
  end

  def welcome
  end
end
