require "test_helper"

class AiFeaturesControllerTest < ActionDispatch::IntegrationTest
  test "should get ingredient_search" do
    get ai_features_ingredient_search_url
    assert_response :success
  end

  test "should get nutrition_analysis" do
    get ai_features_nutrition_analysis_url
    assert_response :success
  end

  test "should get meal_planning" do
    get ai_features_meal_planning_url
    assert_response :success
  end

  test "should get diet_advice" do
    get ai_features_diet_advice_url
    assert_response :success
  end

  test "should get recipe_modification" do
    get ai_features_recipe_modification_url
    assert_response :success
  end
end
