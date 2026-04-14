require "test_helper"

describe FavoritesController do
  describe "Create" do
    test "Should logged in user can favorite a movie" do
      user = users(:one)
      movie = movies(:two)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      assert_difference("Favorite.count", 1) do
        post movie_favorites_path(movie)
      end

      assert_redirected_to movie_path(movie)
      assert_equal "Movie added to favorites.", flash[:notice]
    end

    test "Should not create a duplicated favorite" do
      user = users(:one)
      movie = movies(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      assert_no_difference("Favorite.count") do
        post movie_favorites_path(movie)
      end

      assert_redirected_to movie_path(movie)
      follow_redirect!
      assert_match "Movie added to favorites.", response.body
    end

    test "Should guest cannot create a favorite" do
      movie = movies(:one)

      assert_no_difference("Favorite.count") do
        post movie_favorites_path(movie)
      end
      assert_redirected_to new_session_path
    end

    test "Should return 404 when movie not found" do
      user = users(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      post movie_favorites_path("invalid-slug")

      assert_response :not_found
    end
  end

  describe "Destroy" do
    test "Should user can remove favorite" do
      user = users(:one)
      movie = movies(:two)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      favorite = movie.favorites.create!(user: user)

      assert_difference("Favorite.count", -1) do
        delete movie_favorite_path(movie, favorite)
      end
      assert_raises(ActiveRecord::RecordNotFound) do
        favorite.reload
    end
      assert_redirected_to movie_path(movie)
      assert_equal "Movie removed from favorites.", flash[:notice]
    end

    test "Should not allow a user to delete another user's favorite" do
      another_user = users(:two)
      favorite = favorites(:one)
      movie = favorite.movie

      post session_path, params: { email_or_username: another_user.email, password: "password456" }

      assert_no_difference("Favorite.count") do
        delete movie_favorite_path(movie, favorite)
      end

      assert_response :not_found
    end

    test "Should guest cannot remove a favorite" do
      movie = movies(:one)
      favorite = favorites(:one)

      assert_no_difference ("Favorite.count") do
        delete movie_favorite_path(movie, favorite)
      end

      assert_redirected_to new_session_path
    end
  end
end
