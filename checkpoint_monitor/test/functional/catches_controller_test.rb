require 'test_helper'

class CatchesControllerTest < ActionController::TestCase
  setup do
    @catch = catches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:catches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create catch" do
    assert_difference('Catch.count') do
      post :create, :catch => @catch.attributes
    end

    assert_redirected_to catch_path(assigns(:catch))
  end

  test "should show catch" do
    get :show, :id => @catch.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @catch.to_param
    assert_response :success
  end

  test "should update catch" do
    put :update, :id => @catch.to_param, :catch => @catch.attributes
    assert_redirected_to catch_path(assigns(:catch))
  end

  test "should destroy catch" do
    assert_difference('Catch.count', -1) do
      delete :destroy, :id => @catch.to_param
    end

    assert_redirected_to catches_path
  end
end
