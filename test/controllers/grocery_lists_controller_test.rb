require "test_helper"

class GroceryListsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get grocery_lists_index_url
    assert_response :success
  end

  test "should get show" do
    get grocery_lists_show_url
    assert_response :success
  end

  test "should get new" do
    get grocery_lists_new_url
    assert_response :success
  end

  test "should get create" do
    get grocery_lists_create_url
    assert_response :success
  end

  test "should get edit" do
    get grocery_lists_edit_url
    assert_response :success
  end

  test "should get update" do
    get grocery_lists_update_url
    assert_response :success
  end

  test "should get destroy" do
    get grocery_lists_destroy_url
    assert_response :success
  end
end
