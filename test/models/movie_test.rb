require "test_helper"
describe Movie do
  include ActionDispatch::TestProcess::FixtureFile

  def setup
    @movie = movies(:captainmarvel)
  end

  describe "Validations" do
    test "Should valid with valid attributes" do
      assert @movie.valid?
    end

    test "Should not valid duplicated title" do
      @movie.update!(title: "duplicated")

      movie2 = Movie.new(title: "duplicated")

      refute movie2.valid?
      assert_equal [ "has already been taken" ], movie2.errors[:title]
    end

    test "Should not valid when rating attribute is out the included list " do
      @movie.rating = "GG"

      refute @movie.valid?
      assert_equal [ "is not included in the list" ], @movie.errors[:rating]
    end
  end

  describe "Scopes" do
    test "Should returns only movies already released" do 
      released_movie = movies(:hulk)
      upcoming_movie = movies(:spider6)

      result = Movie.released

      assert_includes result, released_movie
      assert_not_includes result, upcoming_movie
    end

    test "Should returns only movies that have upcoming" do
      released_movie = movies(:hulk)
      upcoming_movie = movies(:spider6)

      result = Movie.upcoming

      assert_includes result, upcoming_movie
      assert_not_includes result, released_movie
    end

    test "Should recent order by released desc" do
      happy = movies(:happyday)
      michael = movies(:michaeljackson)
      boring2 = movies(:boringdays2)

      assert_equal 2, Movie.recent(2).count
      assert_equal [ happy, boring2 ], Movie.recent(2)
    end

    test "hits" do
      hulk    = movies(:hulk)
      captain = movies(:captainmarvel)
      happy   = movies(:happyday)
      boring2  = movies(:boringdays2)

      assert_equal 3, Movie.hits(3).count
      assert_equal [ happy, hulk, captain ], Movie.hits(3).to_a
    end

    test "flops" do
      boring  = movies(:boringdays)
      boring2 = movies(:boringdays2)
      happy   = movies(:happyday)

      assert_equal 2, Movie.flops.count
      assert_equal [ boring2, boring ], Movie.flops
    end

    test "Should returnd only released movies above the given value of gross" do
      low    = movies(:boringdays)
      equal  = movies(:boringdays2)
      high   = movies(:hulk)

      result = Movie.grossed_greater_than(300_000_001)

      assert_includes result, high
      assert_not_includes result, low
      assert_not_includes result, equal
    end

    test "gross less than" do
      low    = movies(:boringdays2)
      equal  = movies(:hulk)
      high   = movies(:happyday)

      result = Movie.grossed_less_than(300_000_000)

      assert_includes result, low
      assert_not_includes result, high
      assert_not_includes result, equal
    end
  end

  describe "Methods/callbacks" do
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

    test "Should return average review" do 
      captain = movies(:captainmarvel)
      reviews(:one)
      reviews(:three)

      assert_equal 4.0, captain.average_stars
  end

    test "Should return 0.0 when there are no reviews" do
      boring = movies(:boringdays)

      assert_equal 0.0, boring.average_stars
    end

    test "Should return the last 3 recently added movies by desc" do
      older  = movies(:happyday)
      middle = movies(:michaeljackson)
      newest = movies(:spider6)


      result = Movie.recently_added

      assert_equal newest, result.first
      assert_equal middle, result.second
      assert_equal older, result.third
    end

    describe "Flop?" do
     test "Should be a flop case" do
        boring2 = movies(:boringdays2)

        assert boring2.flop?
      end

      test "Should not flop" do
        boring = movies(:boringdays)


        refute boring.flop?
      end

      test "Should return false when total gross is high even with low average stars" do
        hulk = movies(:hulk)
        reviews(:two)

        refute hulk.flop?
      end

      test "Should true false when total gross is low and are no reviews" do
        boring2 = movies(:boringdays2)

        assert boring2.flop?
      end
    end
  end
end
