require "test_helper"

describe FavoritesController do
  describe "Create" do
    it "Should logged in user can favorite a movie" do
      sign_in_as(user, password: "password123")
      movie = movies(:hulk)

      assert_difference("Favorite.count", 1) do
        post movie_favorites_path(movie)
      end

      assert_redirected_to movie_path(movie)
      assert_equal "Movie added to favorites.", flash[:notice]
    end

    it "Should not create a duplicated favorite" do
      sign_in_as(user, password: "password123")
      movie = favorites(:one).movie

      assert_no_difference("Favorite.count") do
        post movie_favorites_path(movie)
      end

      assert_redirected_to movie_path(movie)
      assert_equal "Movie added to favorites.", flash[:notice]
    end

    it "Should guest cannot create a favorite" do
      movie = movies(:hulk)

      assert_no_difference("Favorite.count") do
        post movie_favorites_path(movie)
      end

      assert_redirected_to new_session_path
    end

    it "Should return 404 when movie not found" do
      sign_in_as(user, password: "password123")

      post movie_favorites_path("invalid-slug")

      assert_response :not_found
    end
  end

  describe "Destroy" do
    it "Should user can remove favorite" do
      sign_in_as(user,  password: "password123")
      movie = movies(:captainmarvel)
      favorite = favorites(:one)

      assert_difference("Favorite.count", -1) do
        delete movie_favorite_path(movie, favorite)
      end

      assert_redirected_to movie_path(movie)
      assert_equal "Movie removed from favorites.", flash[:notice]
    end

    it "Should not allow a user to delete another user's favorite" do
      favorite = favorites(:one)
      movie = favorite.movie

      sign_in_as(another_user, password: "password456")

      assert_no_difference("Favorite.count") do
        delete movie_favorite_path(movie, favorite)
      end

      assert_response :not_found
    end

    it "Should guest cannot remove a favorite" do
      favorite = favorites(:one)
      movie = favorite.movie

      assert_no_difference("Favorite.count") do
        delete movie_favorite_path(movie, favorite)
      end

      assert_redirected_to new_session_path
    end
  end

  private

  def user
    @user ||= users(:alec)
  end

  def another_user
    @another_user ||= users(:lucio)
  end

  def sign_in_as(user, password:)
    post session_path, params: {
      email_or_username: user.email,
      password: password }
  end
end
