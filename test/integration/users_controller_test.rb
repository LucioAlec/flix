require "test_helper"
describe UsersController do
  describe "Index" do
   test "Should only admin can access the index users page." do
    skip
     get users_path
     assert_match "a", "#{users(:lucio).name}"
   end

   test "Should non admin cannot access the index users page." do
    user = users(:lucio)

    post session_path, params: { email_or_username: user.email, password: "password456" }

    get users_path
    assert_redirected_to movies_path
    assert_equal "Unauthorized access", flash[:alert]
   end

   test "Should guest cannot access the index users page." do
     get users_path

     assert_redirected_to new_session_url
     assert_equal "Please, you must to sign in first!", flash[:alert]
   end
  end
end
