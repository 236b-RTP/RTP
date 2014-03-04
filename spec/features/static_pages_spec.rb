require 'spec_helper'

describe 'Static pages' do

  let(:base_title) { "Real-Time Productivity" }

  describe 'Welcome page' do

    it 'should have the content "Productivity made easy"' do
      visit '/static_pages/welcome'
      expect(page).to have_content('Productivity made easy')
    end

    it "should have the title 'Welcome'" do
      visit '/static_pages/welcome'
      expect(page).to have_title("Welcome | #{base_title}")
    end
  end

  describe "Help page" do

    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end

    it "should have the title 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_title("Help | #{base_title}")
    end
  end

  describe "Settings page" do

    it "should have the content 'Settings'" do
      visit '/static_pages/settings'
      expect(page).to have_content('Settings')
    end

    it "should have the title 'Settings'" do
      visit '/static_pages/settings'
      expect(page).to have_title("Settings | #{base_title}")
    end
  end
end