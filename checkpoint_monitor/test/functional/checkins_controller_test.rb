require 'test_helper'

class CheckinsControllerTest < ActionController::TestCase
  test "should get checkin" do
    get :checkin
    assert_response :success
  end

  test "should get register" do
    get :register
    assert_response :success
  end

  test "should get completed" do
    get :completed
    assert_response :success
  end

end
