require "test_helper"
class MovieTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile


  def setup
    @movie = Movie.new(
      title: "D&A",
      rating: "PG-13",
      total_gross: 1000000000.0,
      description: "A true love history about two pombinhos...",
      released_on: "2022-05-27",
      director: "Us",
      duration: "127min"
    )
  end

  # validations
  test "Should valid with valid attributes" do
    assert @movie.valid?
  end

  # titles
  test "Should not valid title without title" do
    @movie.title = nil

    refute @movie.valid?
    assert_equal [ "can't be blank" ], @movie.errors[:title]
  end

  test "Should not valid duplicated title" do
    @movie.save!

    movie2 = Movie.new(
      title: "D&A",
      rating: "PG",
      total_gross: 9999.9,
      description: "Carol Danvers becomes one of the universe's most p...",
      released_on: "2019-03-08",
      director: "Anna Boden",
      duration: "124min"
    )

    refute movie2.valid?
    assert_equal [ "has already been taken" ], movie2.errors[:title]
  end

  # slug

  test "Should not valid duplicated slug" do
    @movie.save!

    movie2 = Movie.new(
      title: "Captain Shadow",
      rating: "G",
      total_gross: 9999.9,
      description: "Carol Danvers becomes one of the universe's most p...",
      released_on: "2019-03-08",
      director: "Anna Boden",
      duration: "124min"
    )
    movie2.slug = @movie.slug

    refute movie2.valid?
    assert_equal [ "has already been taken" ], movie2.errors[:slug]
  end

  # released_on

  test "Should be not valid movie without released_on attribute" do
    @movie.released_on = nil

    refute @movie.valid?
    assert_includes @movie.errors[:released_on], "can't be blank"
  end

  # duration

  test "Should be not valid movie without duration attribute" do
    @movie.duration = nil

    refute @movie.valid?
    assert_includes @movie.errors[:duration], "can't be blank"
  end


  # description

  test "Should not valid movie without description at least 25 caracters" do
    @movie.description = "s"

    refute @movie.valid?
    assert_equal [ "is too short (minimum is 25 characters)" ], @movie.errors[:description]
  end

  test "Should not valid movie without desciption" do
    @movie.description = nil

    refute @movie.valid?
    assert_equal [ "is too short (minimum is 25 characters)" ], @movie.errors[:description]
  end

  # total_gross

  test "Should not valid total gross attribute less than 0" do
    @movie.total_gross = -1

    refute @movie.valid?
    assert_equal [ "must be greater than or equal to 0" ], @movie.errors[:total_gross]
  end

  test "Should RATINGS array contains 'G', 'PG', 'PG-13', 'R', 'NC-17' values" do
    assert_equal [ "G", "PG", "PG-13", "R", "NC-17" ], Movie::RATINGS
  end

  test "Should not valid when rating attribute is out the included list " do
    @movie.rating = "GG"

    refute @movie.valid?
    assert_equal [ "is not included in the list" ], @movie.errors[:rating]
  end
  #-------------------------------------------------------------------------

  # scopes

  test "Should returns only movies already released" do
    released_movie = Movie.create!(
      title: "D&A",
      rating: "PG-13",
      total_gross: 1000000000.0,
      description: "A true love history about two pombinhos...",
      released_on: 2.days.ago,
      director: "Us",
      duration: "127min"
    )
    upcoming_movie = Movie.create!(
      title: "A&D",
      rating: "PG-13",
      total_gross: 1000000000.0,
      description: "A true love history about two pombinhos...",
      released_on: 2.days.from_now,
      director: "Us",
      duration: "127min"
    )

    result = Movie.released

    assert_includes result, released_movie
    assert_not_includes result, upcoming_movie
  end

  test "Should returns only movies that have upcoming" do
    released_movie = Movie.create!(
      title: "D&A",
      rating: "PG-13",
      total_gross: 1000000000.0,
      description: "A true love history about two pombinhos...",
      released_on: 2.days.ago,
      director: "Us",
      duration: "127min"
    )
    upcoming_movie = Movie.create!(
      title: "A&D",
      rating: "PG-13",
      total_gross: 1000000000.0,
      description: "A true love history about two pombinhos...",
      released_on: 2.days.from_now,
      director: "Us",
      duration: "127min"
    )

    result = Movie.upcoming

    assert_includes result, upcoming_movie
    assert_not_includes result, released_movie
  end

  test "Should returns recent limits the number of released movies returned" do
    3.times do |i|
      Movie.create!(
      title: "movie #{i}",
      rating: "PG-13",
      total_gross: 1000000000.0,
      description: "A true love history about two pombinhos...#{i}",
      released_on: (i + 1).days.ago,
      director: "Us",
      duration: "127min"
      )
    end
      assert_equal 2, Movie.recent(2).count
  end

  test "hits with limit 3" do
    10.times do |i|
      Movie.create!(
      title: "movie #{i}",
      rating: "PG-13",
      total_gross: (299_999_999 + i),
      description: "A true love history about two pombinhos...#{i}",
      released_on: (i + 1).days.ago,
      director: "Us",
      duration: "127min"
      )
    end

    assert_equal 3, Movie.hits(3).count
  end

  test "flops" do
    3.times do |i|
      Movie.create!(
      title: "movie #{i}",
      rating: "PG-13",
      total_gross: (225_000_001 - i),
      description: "A true love history about two pombinhos...#{i}",
      released_on: (i + 1).days.ago,
      director: "Us",
      duration: "127min"
      )
    end

    assert_equal 2, Movie.flops.count
  end

  test "Should returnd only released movies above the given value of gross" do
    low = Movie.create!(
    title: "movie",
    rating: "PG-13",
    total_gross: (300_000_000),
    description: "A true love history about two pombinhos...",
    released_on: 5.days.ago,
    director: "Us",
    duration: "127min"
    )

    equal = Movie.create!(
    title: "movie1",
    rating: "PG-13",
    total_gross: (300_000_001),
    description: "A true love history about two pombinhos...",
    released_on: 5.days.ago,
    director: "Us",
    duration: "127min"
    )

    high = Movie.create!(
    title: "movie2",
    rating: "PG-13",
    total_gross: (300_000_002),
    description: "A true love history about two pombinhos...",
    released_on: 5.days.ago,
    director: "Us",
    duration: "127min"
    )
    result = Movie.grossed_greater_than(300_000_001)

    assert_includes result, high
    assert_not_includes result, low
    assert_not_includes result, equal
  end

  test "gross less than" do
    low = Movie.create!(
    title: "movie",
    rating: "PG-13",
    total_gross: (300_000_000),
    description: "A true love history about two pombinhos...",
    released_on: 5.days.ago,
    director: "Us",
    duration: "127min"
    )

    equal = Movie.create!(
    title: "movie1",
    rating: "PG-13",
    total_gross: (300_000_001),
    description: "A true love history about two pombinhos...",
    released_on: 5.days.ago,
    director: "Us",
    duration: "127min"
    )

    high = Movie.create!(
    title: "movie2",
    rating: "PG-13",
    total_gross: (300_000_002),
    description: "A true love history about two pombinhos...",
    released_on: 5.days.ago,
    director: "Us",
    duration: "127min"
    )

    result = Movie.grossed_less_than(300_000_001)

    assert_includes result, low
    assert_not_includes result, high
    assert_not_includes result, equal
  end


  #-------------------------------------------------------------------------

  # methods/callbacks
  # upcoming?
  test "Should return true to upcoming when released_on attribute  is bigger than current time" do
    @movie.released_on = "2028-05-27"
    @movie.save!

    assert @movie.upcoming?
  end

  test "Should return false to upcoming when released_on attribute  is smaller than current time" do
    @movie.released_on = "2022-05-27"
    @movie.save!

    refute @movie.upcoming?
  end

  # to_param
  test "Should to param returns the slug when movie is saved" do
  @movie.save!

  movie = @movie.to_param

  assert_equal "d-a", movie
  end

  # before save
  test "Should set a slug when movie is saved" do
    @movie.save!
    movie = @movie.slug

    assert_equal "d-a", movie
  end


  # acceptable_image

  test "Should valid with a JPEG main image under 1 megabyte" do
    @movie.main_image.attach(
      io: File.open("test/fixtures/files/smallpng.png"),
      filename: "smallpng.png",
      content_type: "image/png"
    )

    assert @movie.valid?
  end

  test "Should not valid when main image is bigger than 1 megabyte" do
    @movie.main_image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/sceneXL.jpg")),
      filename: "sceneXL.jpg",
      content_type: "image/jpg"
    )

    refute @movie.valid?
    assert_includes @movie.errors[:main_image], "is too big"
  end

  test "Should not valid when main image is not a JPEG or PNG" do
    @movie.main_image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/Capim elefante.xlsx")),
      filename: "Capim elefante.xlsx",
      content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

    refute @movie.valid?
    assert_includes @movie.errors[:main_image], "must be a JPEG or PNG"
  end

  # average_stars
  test "Should return average stars of reviews input" do
    @movie.save!
    Review.create!(
      stars: 4,
      comment: "ULTRA MOVIE",
      movie: @movie,
      user: users(:one)
    )
    Review.create!(
      stars: 5,
      comment: "BEST MOVIE",
      movie: @movie,
      user: users(:two)
    )

    assert_equal 4.5, @movie.average_stars
 end

  test "Should return 0.0 when there are no reviews" do
    @movie.save!

    assert_equal 0.0, @movie.average_stars
  end

  # recently_added?
  test "Should return the last 3 recently added movies by desc" do
  older = Movie.create!(
    title: "Older Movie",
    rating: "PG",
    total_gross: 1000,
    description: "An older movie with enough description.",
    released_on: 5.days.ago,
    director: "Someone",
    duration: "120min",
    created_at: Time.current + 1.minutes
  )

  middle = Movie.create!(
    title: "Middle Movie",
    rating: "PG",
    total_gross: 1000,
    description: "A middle movie with enough description.",
    released_on: 4.days.ago,
    director: "Someone",
    duration: "120min",
    created_at: Time.current + 2.minutes
  )

  newer = Movie.create!(
    title: "Newer Movie",
    rating: "PG",
    total_gross: 1000,
    description: "A newer movie with enough description.",
    released_on: 3.days.ago,
    director: "Someone",
    duration: "120min",
    created_at: Time.current + 3.minutes
  )

  newest = Movie.create!(
    title: "Newest Movie",
    rating: "PG",
    total_gross: 1000,
    description: "The newest movie with enough description.",
    released_on: 2.days.ago,
    director: "Someone",
    duration: "120min",
    created_at: Time.current + 4.minutes
  )

    result = Movie.recently_added

     assert_equal [ newest, newer, middle ], result
     assert_not_includes result, older
  end

  # flop
  test "Return true when average stars are below 4 and total_gross is below 100 million" do
    @movie.total_gross = 50_000_000
    @movie.save!

    Review.create!(
      stars: 2,
      comment: "bad movie",
      movie: @movie,
      user: users(:one)
    )

    assert @movie.flop?
  end

  test "Should return false when average stars are 4 or higher even low gross" do
    @movie.total_gross = 150_000_000
    @movie.save!

    Review.create!(
      stars: 5,
      comment: "bad movie",
      movie: @movie,
      user: users(:one)
    )

    refute @movie.flop?
  end

  test "Should return false when total gross is high even with low average stars" do
    @movie.total_gross = 250_000_000
    @movie.save!

    Review.create!(
      stars: 5,
      comment: "bad movie",
      movie: @movie,
      user: users(:one)
    )

    refute @movie.flop?
  end

  test "Should true false when total gross is low and are no reviews" do
    @movie.total_gross = 50_000_000
    @movie.save!

    assert @movie.flop?
  end
end
