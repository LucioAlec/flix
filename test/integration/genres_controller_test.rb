require "test_helper"
  describe GenresController do
  describe "Index" do
    it "should get genres index" do
      get genres_path
      assert_response :success
      assert_select "h4", "Genres"
      assert_select "li", "#{genres(:scifi).name}"
      assert_select "li", "#{genres(:drama).name}"
    end
  end

  describe "Show" do
    it "should show genre" do
      genre = genres(:scifi)
      movie = genre.movies.first

      get genre_path(genre)
      assert_response :success

      assert_select "h2", "#{genre.name}'s movies"
      assert_select "li", "#{movie.title}"
    end
  end

  describe "New" do
    it "Should only a admin can access a new genre page" do
      sign_in_as_admin

      get new_genre_path
      assert_response :success
    end

    it "Should non admin can not access a new genre page" do
      sign_in_as_non_admin

      get new_genre_path

      assert_redirected_to movies_path

      follow_redirect!

      assert_match "Unauthorized access", response.body
    end
  end

  describe "Create" do
    it "should only admin create a genre" do
      sign_in_as_admin

      assert_difference("Genre.count", 1) do
        post genres_path, params: { genre: { name: "Horror" } }
      end

      assert_response :redirect
      assert_redirected_to genre_path(Genre.last), notice: "Genre created!"
    end

    it "should not create a genre with invalid data" do
      sign_in_as_admin

      assert_no_difference("Genre.count") do
        post genres_path, params: { genre: { name: "" } }
      end

      assert_response :unprocessable_entity
    end

    it "should non admin can not create a genre" do
      sign_in_as_non_admin

      assert_no_difference("Genre.count") do
        post genres_path, params: { genre: { name: "Horror" } }
      end

      assert_redirected_to movies_path
    end
  end

  describe "Edit" do
    it "Should admin can access edit page" do
      sign_in_as_admin
      genre = genres(:scifi)


      get edit_genre_path(genre)
      assert_response :success
    end

    it "Should  non admin cannot access edit page" do
      sign_in_as_non_admin
      genre = genres(:scifi)

      get edit_genre_path(genre)
      assert_redirected_to movies_url
      follow_redirect!
      assert_match "Unauthorized access", response.body
    end
  end

  describe "Update" do
    it "Should non admin can not update a genre" do
      sign_in_as_non_admin
      genre = genres(:scifi)

      assert_no_changes -> { genre.reload.name } do
        patch genre_path(genre), params: { genre: { name: "Updated genre" } }
      end

      assert_redirected_to movies_url
      follow_redirect!
      assert_match "Unauthorized access", response.body
    end

    it "Should only admin can update a genre" do
      sign_in_as_admin
      genre = genres(:scifi)

      patch genre_path(genre), params: { genre: { name: "Updated genre" } }

      genre.reload
      assert_redirected_to genre_path(genre)
      assert_equal "Updated genre", genre.name
    end

    it "Should not update with invalid data" do
      sign_in_as_admin
      genre = genres(:scifi)

      assert_no_changes -> { genre.reload.name } do
        patch genre_path(genre), params: { genre: { name: "" } }
      end

      assert_response :unprocessable_entity
      assert_equal "Genre Unccessfully updated", flash.now[:alert]
    end
  end

  describe "destroy" do
    it "Should only admin can delete a genre" do
      sign_in_as_admin
      genre = genres(:scifi)

      assert_difference("Genre.count", -1) do
      delete genre_path(genre)
      end
      assert_redirected_to genres_path
    end

    it "Should non admin can not delete a genre" do
      sign_in_as_non_admin
      genre = genres(:scifi)

      assert_no_difference("Genre.count") do
      delete genre_path(genre)
      end

      assert_redirected_to movies_url
      follow_redirect!
      assert_match "Unauthorized access", response.body
    end

    it "Should guest can not delete a genre" do
      genre = genres(:scifi)

      assert_no_difference("Genre.count") do
        delete genre_path(genre)
      end
        assert_redirected_to movies_path
    end
  end

  private

    def admin
      @admin ||= users(:alec)
    end

    def non_admin
      @non_admin ||= users(:lucio)
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

    def sign_in_as_non_admin
      sign_in_as(non_admin, password: "password456")
    end
end
