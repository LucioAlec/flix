require "test_helper"

describe ReviewsController do
  describe "index" do
    it "Should guest can not access the index review page" do
      movie = movies(:hulk)

      get movie_reviews_path(movie)

      assert_redirected_to new_session_path

      follow_redirect!
      assert_match "Please, you must to sign in first!", response.body
    end

    it "Should allows users signed-in to access index reviews page" do
      sign_in_as_admin
      movie = movies(:hulk)

      get movie_reviews_path(movie)

      assert_response :success
      assert_select "h1", "Reviews for #{movie.title}"
    end
  end

  describe "New" do
    it "Should allows signed-in user to access new review page" do
      sign_in_as_admin
      movie = movies(:hulk)

      get new_movie_review_path(movie)

      assert_response :success
      assert_select "form"
    end

    it "Should guest can not access a new review page" do
      movie = movies(:hulk)

      get new_movie_review_path(movie)

      assert_redirected_to new_session_path
    end
  end

  describe "Create" do
    it "Should ignores user_id from params and assigns review to current_user" do
      sign_in_as_admin
      another_user = users(:lucio)
      movie = movies(:captainmarvel)

      assert_difference("Review.count", 1) do
        post movie_reviews_path(movie), params: {
          review: valid_review_params.merge(user_id: another_user.id)
        }
      end

      review = Review.last
      assert_equal admin, review.user
      assert_not_equal another_user, review.user
      assert_equal valid_review_params[:stars], review.stars
      assert_equal valid_review_params[:comment], review.comment
    end

    it "Should logged in user can create a review" do
      sign_in_as_admin
      movie = movies(:hulk)

      assert_difference("Review.count", 1) do
        post movie_reviews_path(movie), params: { review: valid_review_params }
      end

      review =  Review.last
      assert_redirected_to movie_reviews_path(movie)
      assert_equal admin, review.user
      assert_equal movie, review.movie
    end

    it "Should guest cannot create a review" do
      movie = movies(:hulk)

      assert_no_difference("Review.count") do
        post movie_reviews_path(movie), params: { review: valid_review_params }
      end

      assert_redirected_to new_session_path
    end

    it "Should logged in user cannot create a review with invalid data" do
      sign_in_as_admin
      movie = movies(:hulk)

      assert_no_difference("Review.count") do
        post movie_reviews_path(movie), params: { review: invalid_review_params }
      end

      assert_response :unprocessable_entity
    end
  end

  describe "Edit" do
    it "Should allows review owner to access edit page" do
      sign_in_as_regular_user
      review = reviews(:two)
      movie = review.movie

      get edit_movie_review_path(movie, review)

      assert_response :success
    end

    it "Shoul allows admin to access edit page for any review" do
      sign_in_as_regular_user
      review = reviews(:two)
      movie = review.movie

      get edit_movie_review_path(movie, review)

      assert_response :success
    end

    it "Should not allow user to edit another user's review" do
      sign_in_as_regular_user
      review = reviews(:one)
      movie = review.movie

      get edit_movie_review_path(movie, review)

      assert_redirected_to movie_reviews_path(movie)
      assert_match "You're not authorized to do that.", flash[:alert]
    end

    it "Should not allow guest can access the edit page" do
      review = reviews(:one)
      movie = review.movie

      get edit_movie_review_path(movie, review)

      assert_redirected_to new_session_url
    end
  end

  describe "Update" do
    it "Should allow review owner to update own review" do
      sign_in_as_regular_user
      review = reviews(:two)
      movie = review.movie

      patch movie_review_path(movie, review), params: {
         review: { stars: 5, comment: "The BEST MOVIE" } }

      review.reload

      assert_redirected_to movie_reviews_path(movie)
      assert_equal "Review updated!", flash[:notice]
      assert_equal "The BEST MOVIE", review.comment
      assert_equal 5, review.stars
    end

    it "Should allows admin to update any review" do
      sign_in_as_admin
      review = reviews(:four)
      movie = review.movie

      patch movie_review_path(movie, review), params: {
         review: { stars: 5, comment: "The BEST MOVIE" }
        }

      review.reload

      assert_redirected_to movie_reviews_path(movie)
      assert_equal "Review updated!", flash[:notice]
      assert_equal "The BEST MOVIE", review.comment
      assert_equal 5, review.stars
    end

    it "Should not allow user to update another user's review" do
      sign_in_as_regular_user
      review = reviews(:one)
      movie = review.movie

      assert_no_changes -> { review.reload.comment } do
        patch movie_review_path(movie, review), params: { review: {
           stars: 5, comment: "The BEST MOVIE" }
          }
      end

      assert_redirected_to movie_reviews_path(movie)
      assert_equal "You're not authorized to do that.", flash[:alert]
    end

    it "Should guest cannot update a review" do
      review = reviews(:one)
      movie = review.movie

      patch movie_review_path(movie, review), params: { review: {
         stars: 5, comment: "The BEST MOVIE" }
        }

      assert_redirected_to new_session_url
      assert_match "Please, you must to sign in first!", flash[:alert]
    end

    it "Should logged in user cannot update a review with invalid data" do
      sign_in_as_regular_user
      review = reviews(:two)
      movie = review.movie

      assert_no_changes -> { review.reload.comment } do
        patch movie_review_path(movie, review), params: {
           review: invalid_review_params }
      end

      assert_response :unprocessable_entity
    end
  end

  describe "Destroy" do
    it "Should admin can delete any review" do
      sign_in_as_admin
      review = reviews(:three)
      movie = review.movie

      assert_difference("Review.count", -1) do
        delete movie_review_path(movie, review)
      end

      assert_redirected_to movie_reviews_path(movie)
    end

    it "Should allow review owner to delete own review" do
      sign_in_as_admin
      review = reviews(:one)
      movie= review.movie

      assert_difference("Review.count", -1) do
        delete movie_review_path(movie, review)
      end

      assert_redirected_to movie_reviews_path(movie)
    end

    it "Should not allow user to delete another user's review" do
      sign_in_as_regular_user
      review = reviews(:one)
      movie = review.movie

      assert_no_difference("Review.count") do
        delete movie_review_path(movie, review)
      end

      assert_redirected_to movie_reviews_path(movie)
      assert_match "You're not authorized to do that.", flash[:alert]
    end

    it "Should guest cannot delete a review" do
      review = reviews(:one)
      movie = review.movie

      assert_no_difference("Review.count") do
        delete movie_review_path(movie, review)
      end

      assert_redirected_to new_session_url
    end
  end

  describe "Missing records/Not found" do
    it "Should raise error when review not found" do
      sign_in_as_admin
      movie = movies(:hulk)


      get edit_movie_review_path(movie, 9999999)

      assert_response :not_found
    end

    it "Should raise error when movie not found" do
      sign_in_as_admin
      review = reviews(:one)


      get edit_movie_review_path("invalid-slug", review)

      assert_response :not_found
    end
  end

  private

    def  admin
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

  def valid_review_params
    { stars: 5, comment: "Great movie!" }
  end

  def invalid_review_params
    { stars: 6, comment: "Invalid stars review" }
  end
end
