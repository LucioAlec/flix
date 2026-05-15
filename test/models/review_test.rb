require "test_helper"

describe Review do
  describe "Validations" do
    it "Should valid with a comment of at least 4 characters " do
      review = Review.new(
        stars: 5, comment: "I like cocunut",
        movie: movies(:hulk), user: users(:alec))

      assert review.valid?
    end

    it "Should not valid when comment is less than 4 characters  " do
      review = Review.new(
        stars: 5, comment: "IDK",
        movie: movies(:hulk), user: users(:alec))

      refute review.valid?
      assert_includes review.errors[:comment], "is too short (minimum is 4 characters)"
    end

    it "Should not valid when stars below allowed range " do
      review = Review.new(
        stars: 0, comment: "I like cocunut",
        movie: movies(:hulk), user: users(:alec))

      refute review.valid?
      assert_equal [ "must be between 1 and 5" ], review.errors[:stars]
    end

    it "Should not valid when stars attribute is above allowed range " do
      review = Review.new(
        stars: 6, comment: "I like cocunut",
        movie: movies(:hulk), user: users(:alec))

      refute review.valid?
      assert_equal [ "must be between 1 and 5" ], review.errors[:stars]
    end

    it "Should not valid when movie attribute nil " do
      review = Review.new(
        stars: 5, comment: "I like cocunut",
        movie: nil, user: users(:alec))

      refute review.valid?
      assert_equal [ "must exist" ], review.errors[:movie]
    end

    it "Should not valid when user attribute is nil " do
      review = Review.new(
        stars: 5, comment: "I like cocunut",
        movie: movies(:hulk), user: nil)

      refute review.valid?
      assert_equal [ "must exist" ], review.errors[:user]
    end
  end
  describe "Scopes" do
    it "Should returns reviews created within the past n days" do
      recent_review = Review.create!(
        stars: 5, comment: "I like cocunut",
        movie: movies(:hulk), user: users(:alec),
        created_at: 2.days.ago)

      old_review = Review.create!(
        stars: 5, comment: "I like cocunut",
        movie: movies(:hulk), user: users(:lucio),
        created_at: 50.days.ago)

        result = Review.past_n_days(3)

        assert_includes result, recent_review
        assert_not_includes result, old_review
    end
  end

  describe "Methods" do
    it "Should convert stars to percent" do
      review = Review.new(
        stars: 5, comment: "I like cocunut",
        movie: movies(:hulk), user: users(:alec))

      result = review.stars_as_percent
      assert_equal 100, result
    end

    it "Should convert stars to percent with intermediated value" do
      review = Review.new(
        stars: 3, comment: "I like cocunut",
        movie: movies(:hulk), user: users(:alec))

      result = review.stars_as_percent
      assert_equal 60, result
    end
  end
end
