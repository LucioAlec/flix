require "test_helper"

describe Genre do
  describe "Validations" do
    test "is valid with a name" do
      genre = Genre.new(name: "Anime")
      assert genre.valid?
    end

    test "is invalid without a name" do
      genre = Genre.new(name: nil)
      refute genre.valid?
      assert_includes genre.errors[:name], "can't be blank"
    end

    test "is not valid with duplicated name" do
      existing_genre = genres(:two)
      genre = Genre.new(name: existing_genre.name)

      refute genre.valid?
      assert_equal [ "has already been taken" ], genre.errors[:name]
    end
  end

  describe "Methods/callbacks" do
    test "Should set a slug when genre is saved" do
      genre = Genre.create!(name: "Anime")
      assert_equal "anime", genre.slug
    end

    test "Should to_param return the slug" do
    genre = genres(:two)
    assert_equal "drama", genre.to_param
    end
  end
end
