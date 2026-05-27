require "test_helper"

describe MoviesController do
  describe "Index" do
    it "Should allow guest to access the movies index page" do
      get movies_path

      assert_response :success
    end

    it "Should show released movies by default" do
      get movies_path

      assert_response :success
      assert_select "a", captainmarvel.title
    end

    it "Should apply allowed movie filter" do
     get movies_path(filter: "hits")

     assert_response :success
     assert_select "a", hulk.title
    end

    it "Should fallback to released movies when movie filter is invalid" do
      get movies_path(filter: "invalid-filter")

      assert_response :success
      assert_select "a", captainmarvel.title
    end
  end

  describe "Show" do
    it "Should allow guest to access a movie show page " do
      get movie_path(captainmarvel)

      assert_response :success
      assert_select "td", captainmarvel.director
    end

    it "Should allow regular user to access a movie show page" do
      sign_in_as_regular_user

      get movie_path(hulk)

      assert_response :success
      assert_select "button", "♡ Unfave"
    end

    it "Should show movie fans" do
      get movie_path(hulk)

      assert_response :success
      assert_select "h4", "Fans"
      assert_select "a", users(:lucio).name
    end

    it "Should show movie genres" do
      get movie_path(captainmarvel)

      assert_response :success
      assert_select "h4", "Genres"
      assert_select "a", genres(:scifi).name
    end

    it "Should not found movie when not exist" do
      get movie_path("invalid")

      assert_response :not_found
    end

    it "Should show fave button when signed-in user has not favorited the movie" do
      sign_in_as_regular_user

      get movie_path(captainmarvel)

      assert_response :success
      assert_select "button", /Fave/
    end
  end

  describe "New" do
    it "Should allow admin to access the new movie page" do
      sign_in_as_admin

      get new_movie_path

      assert_response :success
      assert_select "form"
    end

    it "Should not allow regular user to access the new movie page" do
      sign_in_as_regular_user

      get new_movie_path

      assert_redirected_to movies_url
      assert_equal "Unauthorized access", flash[:alert]
    end

    it "Should not allow guest to access the new movie page" do
      get new_movie_path

      assert_redirected_to new_session_url
      assert_equal "Please, you must to sign in first!", flash[:alert]
    end
  end

  describe "Create" do
    it "Should ignore attributes outside the strong params range" do
      sign_in_as_admin

      assert_difference("Movie.count", 1) do
        post movies_path, params:
          { movie: valid_movie_params.merge(created_at: 10.years.ago) }
      end

      movie = Movie.last
      assert_redirected_to movie
      assert_equal "Movie successufully created! WOW", flash[:notice]
    end

    it "Should allow admin to create a movie" do
      sign_in_as_admin

      assert_difference("Movie.count", 1) do
        post movies_path, params: { movie: valid_movie_params }
      end

      movie = Movie.last
      assert_redirected_to movie
    end

    it "Should not allow regular user to create a movie" do
      sign_in_as_regular_user

      assert_no_difference("Movie.count") do
        post movies_path, params: { movie: valid_movie_params }
      end

      assert_redirected_to movies_url
      assert_equal "Unauthorized access", flash[:alert]
    end

    it "Should not allow guest to create a movie" do
      assert_no_difference("Movie.count") do
        post movies_path, params: { movie: valid_movie_params }
      end

      assert_redirected_to new_session_path
      assert_equal "Please, you must to sign in first!", flash[:alert]
    end

    it "Should not create a movie with invalid data" do
      sign_in_as_admin

      assert_no_difference("Movie.count") do
        post movies_path, params: { movie: invalid_movie_params }
      end

      assert_response :unprocessable_entity
    end
  end

  describe "Edit" do
    it "Should not allow regular user to access the edit movie page" do
      sign_in_as_regular_user

      get edit_movie_path(captainmarvel)

      assert_redirected_to movies_path
      assert_equal "Unauthorized access", flash[:alert]
    end

    it "Should not allow guest to access the edit movie page" do
      get edit_movie_path(captainmarvel)

      assert_redirected_to new_session_url
      assert_equal "Please, you must to sign in first!", flash[:alert]
    end

    it "Should allow admin to access the edit movie page" do
      sign_in_as_admin

      get edit_movie_path(captainmarvel)

      assert_response :success
      assert_select "form"
    end

    it "Should not found when movie does not exist" do
      sign_in_as_admin
      get edit_movie_path("invalid")

      assert_response :not_found
    end
  end

  describe "Update" do
    it "Should ignore attribute outside the strong range" do
      sign_in_as_admin

      assert_no_changes -> { hulk.reload.created_at } do
        patch movie_path(hulk), params:
        { movie: valid_update_movie_params.merge(created_at: 10.years.ago) }
      end

      assert_redirected_to hulk
      assert_equal "Movie successfully updated!", flash[:notice]
    end

    it "Should allow admin to update a movie" do
      sign_in_as_admin

      assert_changes -> { hulk.reload.total_gross }, to: 1000000000 do
        patch movie_path(hulk), params:
        { movie: valid_update_movie_params }
      end

      assert_redirected_to hulk
      assert_equal "Movie successfully updated!", flash[:notice]
    end

    it "Should not allow regular user to update a movie" do
      sign_in_as_regular_user

      assert_no_changes -> { hulk.reload.total_gross } do
        patch movie_path(hulk), params:
        { movie: valid_update_movie_params }
      end

      assert_redirected_to movies_url
      assert_equal "Unauthorized access", flash[:alert]
    end

    it "Should not allow guest to update a movie" do
      assert_no_changes -> { hulk.reload.total_gross } do
        patch movie_path(hulk), params:
        { movie: valid_update_movie_params }
      end

      assert_redirected_to new_session_url
      assert_equal "Please, you must to sign in first!", flash[:alert]
    end

    it "Should not update with invalid data" do
      sign_in_as_admin

      assert_no_changes -> { hulk.reload.title } do
        patch movie_path(hulk), params:
        { movie: valid_update_movie_params.merge(title: "") }
      end

      assert_response :unprocessable_entity
    end
  end

  describe "Destroy" do
    it "Should allow admin to destroy a movie" do
      sign_in_as_admin
      assert_difference("Movie.count", -1) do
        delete movie_path(hulk)
      end

      assert_redirected_to movies_url
      assert_response :see_other
      assert_equal "Movie successfully deleted!", flash[:danger]
    end

    it "Should not allow regular user to destroy a movie" do
      sign_in_as_regular_user

      assert_no_difference("Movie.count") do
        delete movie_path(hulk)
      end

      assert_redirected_to movies_url
      assert_equal "Unauthorized access", flash[:alert]
    end

    it "Should not allow guest to destroy a movie" do
      assert_no_difference("Movie.count") do
        delete movie_path(hulk)
      end

      assert_redirected_to new_session_url
      assert_equal "Please, you must to sign in first!", flash[:alert]
    end

    it "Should return not found when movie does not exist" do
      sign_in_as_admin

      delete movie_path("invalid")

      assert_response :not_found
    end
  end
end

  private

    def hulk
      @hulk ||= movies(:hulk)
    end

    def captainmarvel
      @captainmarvel ||= movies(:captainmarvel)
    end

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

    def valid_movie_params
      {
        title: "Big Hero 6",
        rating: "PG",
        total_gross: 672107599,
        description: "A special bond develops between plus-sized inflatable robot Baymax and prodigy Hiro Hamada, who together team up with a group of friends to form a band of high-tech heroes.",
        released_on: "2014-10-25",
        director: "Don Hall and Chris Williams",
        duration: "102min",
        slug: "big-hero-6"
      }
    end

    def invalid_movie_params
      {
        title: "",
        rating: "PG",
        total_gross: 672_107_599,
        description: "A special bond develops between plus-sized inflatable robot Baymax and prodigy Hiro Hamada, who together team up with a group of friends to form a band of high-tech heroes.",
        released_on: "2014-10-25",
        director: "Don Hall and Chris Williams",
        duration: "102min",
        slug: ""
      }
    end

    def valid_update_movie_params
      {
        title: "Big Hero 6",
        rating: "PG",
        total_gross: 1000000000,
        description: "A special bond develops between plus-sized inflatable robot Baymax and prodigy Hiro Hamada, who together team up with a group of friends to form a band of high-tech heroes.",
        released_on: "2014-10-25",
        director: "Don Hall and Chris Williams",
        duration: "102min",
        slug: "big-hero-6"
      }
    end
