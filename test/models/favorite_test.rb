require "test_helper"

describe Favorite do
  it "Should not valid when the same user try favorite the same movie twice" do
    duplicated_favorited = Favorite.new(user: users(:alec), movie: movies(:captainmarvel))

    refute duplicated_favorited.valid?
    assert_equal [ "has already been taken" ], duplicated_favorited.errors[:user_id]
  end

  it "Should valid when different users favorite the same movie" do
    another_favorite = Favorite.new(user: users(:lucio), movie: movies(:captainmarvel))

    assert another_favorite.valid?
  end

  it "Should valid when the same user favorite different movies" do
    another_favorited_movie = Favorite.new(user: users(:alec), movie: movies(:hulk))

    assert another_favorited_movie.valid?
  end
end
=begin  def setup
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
      email: "alec1@example.com",
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
=end
=begin  it "Should not valid without user" do
    favorite_without_user = Favorite.new(
      movie: movies(:one),
      user: nil
    )
    refute favorite_without_user.valid?
    assert_includes favorite_without_user.errors[:user], "must exist"
  end

  it "Should not valid without movie" do
    favorite_without_movie = Favorite.new(
      movie: nil,
      user: users(:one)
    )
    refute favorite_without_movie.valid?
    assert_includes favorite_without_movie.errors[:movie], "must exist"
  end
=end
