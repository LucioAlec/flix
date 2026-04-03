require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test "Should Stars array contains 1,2,3,4,5 values" do
    assert_equal [ 1, 2, 3, 4, 5 ], Review::STARS
  end

  test "Should valid with a comment of at least 4 characters " do
    review = Review.new(
      stars: 5, comment: "I like cocunut",
      movie: movies(:one), user: users(:one))

    assert review.valid?
  end

  test "Should not valid when comment is less than 4 characters  " do
    review = Review.new(
      stars: 5, comment: "IDK",
      movie: movies(:one), user: users(:one))

    refute review.valid?
    assert_includes review.errors[:comment], "is too short (minimum is 4 characters)"
  end

  test "Should not valid when stars attribute is less than 1 or bigger than 5 " do
    review = Review.new(
      stars: 0, comment: "I like cocunut",
      movie: movies(:one), user: users(:one))

    refute review.valid?
    assert_equal [ "must be between 1 and 5" ], review.errors[:stars]
  end

  test "Should not valid when stars attribute is bigger than 5 " do
    review = Review.new(
      stars: 6, comment: "I like cocunut",
      movie: movies(:one), user: users(:one))

    refute review.valid?
    assert_equal [ "must be between 1 and 5" ], review.errors[:stars]
  end
  #
  test "Should not valid when movie attribute nil " do
    review = Review.new(
      stars: 5, comment: "I like cocunut",
      movie: nil, user: users(:one))

    refute review.valid?
    assert_equal [ "must exist" ], review.errors[:movie]
  end

  test "Should not valid when user attribute is nil " do
    review = Review.new(
      stars: 5, comment: "I like cocunut",
      movie: movies(:one), user: nil)

    refute review.valid?
    assert_equal [ "must exist" ], review.errors[:user]
  end
  #
  test "Should returns reviews created in the past n days" do
    recent_review = Review.create!(
      stars: 5, comment: "I like cocunut",
      movie: movies(:one), user: users(:one),
      created_at: 2.days.ago)

    old_review = Review.create!(
      stars: 5, comment: "I like cocunut",
      movie: movies(:one), user: users(:two),
      created_at: 50.days.ago)

      result = Review.past_n_days(3)

      assert_includes result, recent_review
      assert_not_includes result, old_review
  end

  test "Should convert stars to percent" do
    review = Review.new(
      stars: 5, comment: "I like cocunut",
      movie: movies(:one), user: users(:one))

    result = review.stars_as_percent
    assert_equal 100, result
  end

  test "Should convert stars to percent with intermediated value" do
    review = Review.new(
      stars: 3, comment: "I like cocunut",
      movie: movies(:one), user: users(:one))

    result = review.stars_as_percent
    assert_equal 60, result
  end
end
