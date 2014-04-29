require 'spec_helper'

describe Preference do
	before do
		@preference = Preference.new(profile_type: "foo", start_time: DateTime.now, end_time: DateTime.now)
	end
  subject { @preference }

  it { should respond_to(:profile_type) }
  it { should respond_to(:start_time) }
  it { should respond_to(:end_time) }
  describe 'when profile type is not present' do
    before { @preference.profile_type = '' }
    it { should_not be_valid }
  end

  describe 'when start_time is not present' do
    before { @preference.start_time = nil}
    it { should_not be_valid }
  end

  describe 'when end_time is not present' do
    before { @preference.end_time = nil }
    it { should_not be_valid }
  end
end
