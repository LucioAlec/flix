require "test_helper"

class GenresControllerTest < ActionDispatch::IntegrationTest
  test "should access gender page" do
    get "/genres"
    assert_response :success
    assert_select "h4", "Genres"
  end

  test "should create a genre" do
    user = users(:one)
    post "/session", params: { email_or_username: user.email, password: "password123" }

    assert_response :redirect
    follow_redirect!

    get "/genres/new"
    assert_response :success
  end
end
