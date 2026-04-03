require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  test "should get the sign in page" do
    get "/signin"
    assert_response :success
  end
end
