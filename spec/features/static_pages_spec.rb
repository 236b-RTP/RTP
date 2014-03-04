require 'spec_helper'

describe 'Static pages' do

  describe 'Welcome page' do
    it 'should have the content "Productivity made easy"' do
      visit '/static_pages/welcome'
      expect(page).to have_content('Productivity made easy')
    end
  end

  describe "Help page" do
    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end
  end

  describe "Settings page" do
    it "should have the content 'Settings'" do
      visit '/static_pages/settings'
      expect(page).to have_content('Settings')
    end
  end
end