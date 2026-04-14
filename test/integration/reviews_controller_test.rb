require "test_helper"

describe ReviewsController do
  describe "index" do
    test "Should guest can not access the index review page" do
      movie = movies(:one)

      get movie_reviews_path(movie)

      assert_response :redirect
      assert_redirected_to new_session_path

      follow_redirect!
      assert_match "Please, you must to sign in first!", response.body
    end

    test "Should only users logged in can access the index review page" do
      user = users(:one)
      post session_path, params: { email_or_username: user.email, password: "password123" }
      movie = movies(:one)

      get movie_reviews_path(movie)

      assert_response :success
   end
  end

  describe "New" do
    test "Should only logged user can access a new review page" do
      user  = users(:one)
      movie = movies(:one)
      post session_path, params: { email_or_username: user.email, password: "password123" }

      get new_movie_review_path(movie)

      assert_response :success
    end

    test "Should guest can not access a new review page" do
      movie = movies(:one)

      get new_movie_review_path(movie)

      assert_response :redirect
      assert_redirected_to new_session_path
    end
  end

  describe "Create" do
    test "Should not allow user_id to be set via params" do
      user = users(:one)
      other_user = users(:two)
      movie = movies(:two)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      post movie_reviews_path(movie), params: { review: { stars: 4, comment: "blablabla", user_id: other_user.id } }

      review = Review.last
      assert_equal user, review.user
    end

    test "Should logged in user can create a review" do
      user = users(:one)
      movie = movies(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      assert_difference("Review.count", 1) do
        post movie_reviews_path(movie), params: { review: { stars: reviews(:one).stars, comment: reviews(:one).comment } }
      end

      review =  Review.last

      assert_response :redirect
      assert_redirected_to movie_reviews_path(movie)
      assert_equal user, review.user
      assert_equal movie, review.movie
    end

    test "Should guest cannot create a review" do
      movie = movies(:one)

      assert_no_difference("Review.count") do
        post movie_reviews_path(movie), params: { review: { stars: "5", comment: "Its the best movie I've seen since Pele's movie" } }
      end

      assert_response :redirect
      assert_redirected_to new_session_path
    end

    test "Should logged in user cannot create a review with invalid data" do
      user = users(:one)
      movie = movies(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }


      assert_no_difference("Review.count", 1) do
        post movie_reviews_path(movie), params: { review: { stars: 6, comment: "a" } }
      end

      assert_response :unprocessable_entity
    end
  end

  describe "Edit" do
    test "Should logged can access the edit page" do
      user = users(:one)
      movie = movies(:one)
      review = reviews(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      get edit_movie_review_path(movie, review)

      assert_response :success
    end

    test "Should logged in user can update your own review" do
      user = users(:one)
      movie = movies(:one)
      review = reviews(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      get edit_movie_review_path(movie, review)

      assert_response :success
    end

    test "Should not allow user to edit another user's review" do
      user = users(:two)
      movie = movies(:one)
      review = reviews(:one)

      post session_path, params: { email_or_username: user.email, password: "password456" }

      get edit_movie_review_path(movie, review)

      assert_response :redirect
      assert_redirected_to movie_reviews_path(movie)
      assert_match "You're not authorized to do that.", flash[:alert]
    end

    test "Should guest cannot access the edit page" do
      movie = movies(:one)
      review = reviews(:one)

      get edit_movie_review_path(movie, review)

      assert_response :redirect
      assert_redirected_to new_session_url
    end
  end

  describe "Update" do
    test "Should logged in user can update your own review" do
      user = users(:one)
      movie = movies(:one)
      review = reviews(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      patch movie_review_path(movie, review), params: { review: { stars: 5, comment: "The BEST MOVIE" } }

      assert_response :redirect
      assert_redirected_to movie_reviews_path(movie)
      assert_equal "Review updated!", flash[:notice]
    end

    test "Should admin can update any review" do
      user = users(:one)
      movie = movies(:two)
      review = reviews(:two)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      patch movie_review_path(movie, review), params: { review: { stars: 5, comment: "The BEST MOVIE" } }

      assert_response :redirect
      assert_redirected_to movie_reviews_path(movie)
      assert_equal "Review updated!", flash[:notice]
      review.reload
      assert_equal "The BEST MOVIE", review.comment
      assert_equal 5, review.stars
    end

    test "Should not allow user to update another user's review" do
      user = users(:two)
      movie = movies(:one)
      review = reviews(:one)

      post session_path, params: { email_or_username: user.email, password: "password456" }

      patch movie_review_path(movie, review), params: { review: { stars: 5, comment: "The BEST MOVIE" } }

      assert_response :redirect
      assert_redirected_to movie_reviews_path(movie)
    end

    test "Should guest cannot update a review" do
      movie = movies(:one)
      review = reviews(:one)

      patch movie_review_path(movie, review), params: { review: { stars: 5, comment: "The BEST MOVIE" } }

      assert_response :redirect
      assert_redirected_to new_session_url
      assert_match "Please, you must to sign in first!", flash[:alert]
    end

    test "Should logged in user cannot update a review with invalid data" do
      user = users(:one)
      movie = movies(:one)
      review = reviews(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }


      assert_no_difference("Review.count", 1) do
        patch movie_review_path(movie, review), params: { review: { stars: 6, comment: "a" } }
      end

      assert_response :unprocessable_entity
    end
  end

  describe "Destroy" do
    test "Should admin can delete any review" do
      user = users(:one)
      movie = movies(:two)
      review = reviews(:two)

        post session_path, params: { email_or_username: user.email, password: "password123" }

      assert_difference("Review.count", -1) do
       delete movie_review_path(movie, review)
      end

      assert_raises(ActiveRecord::RecordNotFound) do
        review.reload
      end
      assert_response :redirect
      assert_redirected_to movie_reviews_path(movie)
    end

    test "Should user can delete your own review" do
      user = users(:one)
      review = reviews(:one)
      movie= review.movie

      post session_path, params: { email_or_username: user.email, password: "password123" }

      assert_difference("Review.count", -1) do
       delete movie_review_path(movie, review)
      end
      assert_raises(ActiveRecord::RecordNotFound) do
        review.reload
      end
      assert_response :redirect
      assert_redirected_to movie_reviews_path(movie)
    end

    test "Should user cannot delete other reviews when he isnt a admin" do
      user = users(:two)
      movie = movies(:one)
      review = reviews(:one)

      post session_path, params: { email_or_username: user.email, password: "password456" }

      assert_no_difference("Review.count") do
      delete movie_review_path(movie, review)
      end

      assert_response :redirect
      assert_redirected_to movie_reviews_path(movie)
      assert_match "You're not authorized to do that.", flash[:alert]
    end

    test "Should guest cannot delete any review" do
      movie = movies(:one)
      review = reviews(:one)

      assert_no_difference("Review.count") do
        delete movie_review_path(movie, review)
      end

      assert_response :redirect
      assert_redirected_to new_session_url
    end
  end

  describe "Methods/callbacks" do
    test "Should raise error when review not found" do
      user = users(:one)
      movie = movies(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      get edit_movie_review_path(movie, 9999999)

      assert_response :not_found
    end

    test "Should raise error when movie not found" do
      user = users(:one)
      review = reviews(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      get edit_movie_review_path(787, review)

      assert_response :not_found
    end
  end
end
