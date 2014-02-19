require 'test_helper'

class CalendarsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get preferences" do
    get :preferences
    assert_response :success
  end

  test "should get add_task" do
    get :add_task
    assert_response :success
  end

end
