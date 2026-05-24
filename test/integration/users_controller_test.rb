require "test_helper"
describe UsersController do
  describe "Index" do
    it "Should allow admin to access the index users page." do
      sign_in_as_admin

      get users_path
      assert_response :success
      assert_select "h1", "2 Users"
      assert_select "a", regular_user.name
      assert_select "a", users(:Balec).name
    end

    it "Should index users page show only not admins users" do
      sign_in_as_admin

      get users_path
      assert_select "h1", "2 Users"
    end

    it "Should not allow non-admin access the index users page." do
      sign_in_as_regular_user

      get users_path

      assert_redirected_to movies_path
      assert_equal "Unauthorized access", flash[:alert]
    end

    it "Should not allow guest access the index users page." do
      get users_path

      assert_redirected_to new_session_url
      assert_equal "Please, you must to sign in first!", flash[:alert]
    end
  end

  describe "Show" do
    it "Should allow signed-in user to access your own show page" do
      sign_in_as_regular_user

      get user_path(regular_user)

      assert_response :success
      assert_select "h1", regular_user.name
    end

    it "Should allow signed-in to access others user show page" do
      sign_in_as_regular_user

      get user_path(admin)

      assert_response :success
      assert_select "h1", admin.name
    end

    it "Should not allow guest to access a show page " do
      get user_path(regular_user)

      assert_redirected_to new_session_url
      assert_equal "Please, you must to sign in first!", flash[:alert]
    end
  end

  describe "New" do
    it "Should allow guest to access a new user page" do
      get new_user_path

      assert_response :success
      assert_select "form"
    end
  end

  describe "Create" do
    it "Should allow guest to create a user" do
      assert_difference("User.count", 1) do
        post users_path, params:
        { user: valid_user_params }
      end

      created_user = User.last
      assert_redirected_to user_path(created_user)
      assert_equal "User sucessfully created!!!", flash[:notice]
    end

    it "Should ignore attributes outside the strong_params range" do
      assert_difference("User.count", 1) do
        post users_path, params:
        { user: valid_user_params.merge(admin: true) }
      end

      created_user = User.last
      assert_redirected_to user_path(created_user)
      refute created_user.admin?
    end

    it "Should sign in newly created user" do
      post users_path, params: { user: valid_user_params }

      follow_redirect!

      assert_response :success
      created_user = User.last
      assert_select "h1", valid_user_params[:name]
      assert_select "h1", created_user.name
    end

    it "Should not create user with invalid data" do
      assert_no_difference("User.count") do
        post users_path, params:
        { user: valid_user_params.merge(email: "invalid-email") }
      end

      assert_response :unprocessable_entity
    end
  end

  describe "Edit" do
    it "Should allow regular user access your own edit user page" do
      sign_in_as_regular_user

      get edit_user_path(regular_user)

      assert_response :success
    end

    it "Should allow admin access others edit user page" do
      sign_in_as_admin

      get edit_user_path(admin)

      assert_response :success
    end

    it "Should not allow regular user access others edit user page" do
      sign_in_as_regular_user

      get edit_user_path(admin)

      assert_redirected_to root_path
    end

    it "Should not allow guest access others edit user page" do
      get edit_user_path(admin)

      assert_redirected_to new_session_url
    end

    it "Should return 404 when user doesn't exist" do
      sign_in_as_admin

      get edit_user_path("invalid-slug")

      assert_response :not_found
    end
  end

  describe "Update" do
    it "Should not allow regular user to set admin through params" do
      sign_in_as_regular_user

      assert_no_changes -> { regular_user.reload.admin? } do
        patch user_path(regular_user), params:
        { user: valid_user_update_params(regular_user, password: "password456").
          merge(admin: true) }
      end

      assert_redirected_to user_path(regular_user)
      refute regular_user.admin?
    end

    it "Should allow admin give a admin permission to others users" do
      sign_in_as_admin

      assert_changes -> { regular_user.reload.admin? }, from: false, to: true do
        patch user_path(regular_user), params:
        { user: valid_user_update_params(regular_user, password: "password456").
          merge(admin: true) }
      end

      assert_redirected_to user_path(regular_user)

      assert regular_user.admin?
      assert_equal "Account successfully updated!", flash[:notice]
    end

    it "Should not allow regular user update others users profile" do
      sign_in_as_regular_user

      assert_no_changes -> { admin.reload.name } do
        patch user_path(admin), params:
        { user: { name: "Alexx" } }
      end

      assert_redirected_to root_url
      assert_response :see_other
    end

    it "Should allow admin update others users profile" do
      sign_in_as_admin

      assert_changes -> { regular_user.reload.name } do
        patch user_path(regular_user), params:
        { user: valid_user_update_params(regular_user, password: "password456").
          merge(name: "Alexx") }
      end

      assert_redirected_to user_path(regular_user)

      assert_equal "Account successfully updated!", flash[:notice]
    end

    it "Should not update user with invalid data" do
      sign_in_as_admin

      assert_no_changes -> { admin.reload.name } do
        patch user_path(admin), params:
        { user: valid_user_update_params(regular_user, password: "password456").
          merge(name: "") }
      end

      assert_response :unprocessable_entity
    end
  end

  describe "destroy" do
    it "Should allow regular user delete your own user profile" do
      sign_in_as_regular_user

      assert_difference("User.count", -1) do
        delete user_path(regular_user)
      end

      assert_redirected_to root_url
      assert_equal "Account successfully deleted!", flash[:notice]
    end

    it "Should redirect to new session url after self delete" do
      sign_in_as_regular_user

      delete user_path(regular_user)

      get user_path(regular_user)

      assert_redirected_to new_session_url
    end

    it "Should not allow regular user delete other users profile" do
      sign_in_as_regular_user

      assert_no_difference("User.count") do
        delete user_path(admin)
      end

      assert_redirected_to root_url
      assert_response :see_other
    end

    it "Should allow admin delete other users profile" do
      sign_in_as_admin

      assert_difference("User.count", -1) do
        delete user_path(regular_user)
      end

      assert_redirected_to users_url
      assert_equal "Account successfully deleted!", flash[:alert]
    end

    it "Should not allow guest delete other users profile" do
      assert_no_difference("User.count") do
        delete user_path(regular_user)
      end

      assert_redirected_to new_session_url
      assert_equal "Please, you must to sign in first!", flash[:alert]
    end
  end

  private

    def admin
      @admin ||= users(:alec)
    end

    def regular_user
      @regular_user ||= users(:lucio)
    end

    def sign_in_as(user, password:)
      post session_path, params: {
        email_or_username: user.email,
        password: password
      }
    end

    def sign_in_as_admin
      sign_in_as(admin, password: "password123")
    end

    def sign_in_as_regular_user
      sign_in_as(regular_user, password: "password456")
    end

    def valid_user_params
      {
        name: "Otavio",
        username: "otavio",
        email: "otavio@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    def valid_user_update_params(user, password:)
      {
        name: user.name,
        username: user.username,
        email: user.email,
        password: password,
        password_confirmation: password
      }
    end
end
