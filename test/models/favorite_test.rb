require "test_helper"

class FavoriteTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "Allec",
      username: "Allec34",
      email: "alec@examplle.com",
      password: "1234567890",
      password_confirmation: "1234567890"
    )
    @user2 = User.create!(
      name: "Alec",
      username: "Alec34",
      email: "alec@example.com",
      password: "1234567890",
      password_confirmation: "1234567890"
    )

    @movie = Movie.create!(
      title: "Matrix",
      rating: "PG-13",
      total_gross: 9.99,
      description: "Carol Danvers becomes one of the universe's most p...",
      released_on: "2019-03-08",
      director: "Anna Boden",
      duration: "124min",
      slug: "matrix"
    )

    @movie2 = Movie.create!(
      title: "Avengers",
      rating: "PG-13",
      total_gross: 9.99,
      description: "Carol Danvers becomes one of the universe's most p...",
      released_on: "2019-03-08",
      director: "Anna Boden",
      duration: "124min",
      slug: "avengers"
    )
  end

  test "Should valid with user and movie" do
    favorite = Favorite.new(user: @user, movie: @movie)
    assert favorite.valid?
  end

  test "Should not valid without user" do
    favorite_without_user = Favorite.new(
      movie: movies(:one),
      user: nil
    )
    refute favorite_without_user.valid?
    assert_includes favorite_without_user.errors[:user], "must exist"
  end

  test "Should not valid without movie" do
    favorite_without_movie = Favorite.new(
      movie: nil,
      user: users(:one)
    )
    refute favorite_without_movie.valid?
    assert_includes favorite_without_movie.errors[:movie], "must exist"
  end

  test "Should not valid when the same user try favorite the same movie twice" do
    Favorite.create!(user: @user, movie: @movie)
    duplicated_favorited = Favorite.new(user: @user, movie: @movie)

    refute duplicated_favorited.valid?
    assert_equal [ "has already been taken" ], duplicated_favorited.errors[:user_id]
  end

  test "Should valid when different users favorite the same movie" do
    Favorite.create!(user: @user, movie: @movie)
    another_favorite = Favorite.new(user: @user2, movie: @movie)

    assert another_favorite.valid?
  end

  test "Should valid when the same user favorite different movies" do
    Favorite.create!(user: @user, movie: @movie)
    another_favorited_movie = Favorite.new(user: @user, movie: @movie2)

    assert another_favorited_movie.valid?
  end
end
