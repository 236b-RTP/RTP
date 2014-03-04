require 'spec_helper'

describe 'Static pages' do

  let(:base_title) { "Real-Time Productivity" }

  describe 'Welcome page' do
    before { visit root_path }

    it 'should have the content "Productivity made easy"' do
      expect(page).to have_content('Productivity made easy')
    end

    it "should have the title 'Welcome'" do
      expect(page).to have_title("Welcome | #{base_title}")
    end
  end

  describe "Help page" do
    before { visit help_path }

    it "should have the content 'Help'" do
      expect(page).to have_content('Help')
    end

    it "should have the title 'Help'" do
      expect(page).to have_title("Help | #{base_title}")
    end
  end

  describe "Settings page" do
    before { visit settings_path }

    it "should have the content 'Settings'" do
      expect(page).to have_content('Settings')
    end

    it "should have the title 'Settings'" do
      expect(page).to have_title("Settings | #{base_title}")
    end
  end
end