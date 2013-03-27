require 'test_helper'

class AlignmentsControllerTest < ActionController::TestCase
  setup do
    @alignment = alignments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alignments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create alignment" do
    assert_difference('Alignment.count') do
      post :create, alignment: { changes: @alignment.changes, dir: @alignment.dir, exon_gtf: @alignment.exon_gtf, name: @alignment.name, reverse: @alignment.reverse, seq_name: @alignment.seq_name }
    end

    assert_redirected_to alignment_path(assigns(:alignment))
  end

  test "should show alignment" do
    get :show, id: @alignment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @alignment
    assert_response :success
  end

  test "should update alignment" do
    put :update, id: @alignment, alignment: { changes: @alignment.changes, dir: @alignment.dir, exon_gtf: @alignment.exon_gtf, name: @alignment.name, reverse: @alignment.reverse, seq_name: @alignment.seq_name }
    assert_redirected_to alignment_path(assigns(:alignment))
  end

  test "should destroy alignment" do
    assert_difference('Alignment.count', -1) do
      delete :destroy, id: @alignment
    end

    assert_redirected_to alignments_path
  end
end
