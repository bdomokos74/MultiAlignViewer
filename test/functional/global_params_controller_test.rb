require 'test_helper'

class GlobalParamsControllerTest < ActionController::TestCase
  setup do
    @global_param = global_params(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:global_params)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create global_param" do
    assert_difference('GlobalParam.count') do
      post :create, global_param: { key: @global_param.key, value: @global_param.value }
    end

    assert_redirected_to global_param_path(assigns(:global_param))
  end

  test "should show global_param" do
    get :show, id: @global_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @global_param
    assert_response :success
  end

  test "should update global_param" do
    put :update, id: @global_param, global_param: { key: @global_param.key, value: @global_param.value }
    assert_redirected_to global_param_path(assigns(:global_param))
  end

  test "should destroy global_param" do
    assert_difference('GlobalParam.count', -1) do
      delete :destroy, id: @global_param
    end

    assert_redirected_to global_params_path
  end
end
