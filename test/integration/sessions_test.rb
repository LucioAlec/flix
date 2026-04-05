require "test_helper"

describe SessionsController do
  describe "New session" do
    test "Should get the sign in page" do
      get "/signin"
      assert_response :success
      assert_select "h1", "Sign in"
    end
  end

  describe "Creating sesion" do
    test "Should sign with valid email" do
      user = users(:one)

      post "/session", params: {
        email_or_username: user.email,
        password: "password123"
      }
      assert_response :redirect
      assert_redirected_to user_path(user)
      assert_equal user.id, session[:user_id]
      assert_equal "Welcome back, #{user.name}!", flash[:notice]

      follow_redirect!
      assert_response :success
    end

    test "Should sign with valid username" do
      user = users(:one)

      post "/session", params: {
        email_or_username: user.username,
        password: "password123"
      }
      assert_response :redirect
      assert_redirected_to user_path(user)

      follow_redirect!
      assert_response :success
    end

    test "Should not sign with incorret password" do
      user = users(:one)

      post "/session", params: {
        email_or_username: user.email,
        password: "password1234"
      }
      assert_response :unprocessable_entity
      assert_equal "Invalid email/password combination!", flash.now[:alert]
      assert_select "div", /invalid/i  # força Rails processar a view
    end

    test "Should not sign in when user do not exist" do
      post "/session", params: {
        email_or_username: "nonexistuser@em.com",
        password: "password1234"
      }
      assert_response :unprocessable_entity
      assert_equal "Invalid email/password combination!", flash.now[:alert]
    end
  end

  describe "Destroying session" do
    test "Should logout" do
      user = users(:one)

      post "/session", params: {
        email_or_username: user.email,
        password: "password1234"
      }

      delete session_path
      assert_redirected_to movies_path
      assert_response :see_other
      assert_nil session[:user_id]
      assert_equal "You're now signed out!", flash[:alert]
    end
  end
end
