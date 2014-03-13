require 'minitest/spec'
require 'minitest/autorun'
require 'Pry'
require_relative 'task_placer.rb'

describe TaskPlacer do 
	before do
		@tp = Taskplacer.new
	end

	it "can be initialized" do
		Taskplacer.new.wont_be_nil
	end

	it "will error" do
		proc{ @tp.task_order(5, 3, 2) }.must_raise ArgumentError
	end

	it "area correct" do
		@tp.task_order(2, 3, 7).must_equal 
	end

end

