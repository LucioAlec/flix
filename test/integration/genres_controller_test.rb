require "test_helper"

  describe GenresController do
    test "should get genres index" do
      get genres_path
      assert_response :success
      assert_select "h4", "Genres"
      assert_select "li", "#{genres(:one).name}"
      assert_select "li", "#{genres(:two).name}"
    end

    test "should show genre" do
      genre = genres(:one)
      movie = genre.movies.first

      get genre_path(genre.slug)
      assert_response :success

      assert_select "h2", "#{genre.name}'s movies"
      assert_select "li", "#{movie.title}"
    end

  describe "New" do
    test "Should only a admin can access a new genre page" do
      user = users(:one)
      post session_path, params: { email_or_username: user.email, password: "password123" }

      get new_genre_path
      assert_response :success
    end

    test "Should non admin can not access a new genre page" do
      user = users(:two)


      post session_path, params: { email_or_username:  user.email, password: "password123" }

      get new_genre_path

      assert_response :redirect
      assert_redirected_to movies_path

      follow_redirect!

      assert_match "Unauthorized access", response.body
    end
  end

  describe "Create" do
    test "should only admin create a genre" do
      user = users(:one)
      post session_path, params: { email_or_username: user.email, password: "password123" }

      assert_difference("Genre.count", 1) do
        post genres_path, params: { genre: { name: "Horror" } }
      end

      assert_response :redirect
    end

    test "should not create a genre with invalid data" do
      user = users(:one)
      post session_path, params: { email_or_username: user.email, password: "password123" }

      assert_no_difference("Genre.count") do
        post genres_path, params: { genre: { name: "" } }
      end

      assert_response :unprocessable_entity
    end

    test "should non admin can not create a genre" do
      user = users(:two)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      post genres_path, params: { genre: { name: "Horror" } }

      assert_response :redirect
      assert_redirected_to movies_path

      follow_redirect!

      assert_match "Unauthorized access", response.body
    end
  end

  describe "Edit" do
    test "Should admin can access edit page" do
      user = users(:one)
      genre = genres(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      get edit_genre_path(genre.slug)
      assert_response :success
    end

    test "Should  non admin cannot access edit page" do
      user = users(:two)
      genre = genres(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      get edit_genre_path(genre.slug)
      assert_response :redirect
      follow_redirect!
      assert_match "Unauthorized access", response.body
    end
  end

  describe "Update" do
    test "Should non admin can not update a genre" do
      user = users(:two)
      genre = genres(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      patch genre_path(genre.slug), params: { genre: { name: "Updated genre" } }
      assert_response :redirect
      follow_redirect!
      assert_match "Unauthorized access", response.body
    end

    test "Should only admin can update a genre" do
      user = users(:one)
      genre = genres(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      patch genre_path(genre.slug), params: { genre: { name: "Updated genre" } }
      assert_response :redirect
      genre.reload
      assert_equal "Updated genre", genre.name
    end

    test "Should not update with invalid data" do
      user = users(:one)
      genre = genres(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      patch genre_path(genre.slug), params: { genre: { name: "" } }

      assert_response :unprocessable_entity
      assert_equal "Genre Unccessfully updated", flash.now[:alert]
    end
  end

  describe "destroy" do
    test "Should only admin can delete a genre" do
      user = users(:one)
      genre = genres(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      assert_difference("Genre.count", -1) do
      delete genre_path(genre.slug)
      end
      assert_redirected_to genres_path
    end

    test "Should non admin can not delete a genre" do
      user = users(:two)
      genre = genres(:one)

      post session_path, params: { email_or_username: user.email, password: "password123" }

      assert_no_difference("Genre.count") do
      delete genre_path(genre.slug)
      end

      assert_response :redirect
      follow_redirect!
      assert_match "Unauthorized access", response.body
    end

    test "Should guest can not delete a genre" do
      genre = genres(:one)

      assert_no_difference("Genre.count") do
        delete genre_path(genre.slug)
      end
        assert_redirected_to movies_path
    end
  end
end
