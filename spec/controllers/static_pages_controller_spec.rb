require 'spec_helper'

describe StaticPagesController do

  describe "GET 'help'" do
    it "returns http success" do
      get 'help'
      response.should be_success
    end
  end

  describe "GET 'settings'" do
    it "returns http success" do
      get 'settings'
      response.should be_success
    end
  end

  describe "GET 'welcome'" do
    it "returns http welcome" do
      get 'welcome'
      response.should be_success
    end
  end

end
