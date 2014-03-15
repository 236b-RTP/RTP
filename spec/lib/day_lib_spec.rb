require 'rspec'
require_relative 'day.rb'
describe Day do 
	before do
		@d = Day.new
		@busy = {begin: 10, end: 20}
	end

	it "can be initialized" do
		Day.new.wont_be_nil
	end

	it "can insert busy" do
		d.insert(@busy).to be true
	end
		

end