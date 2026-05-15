require "test_helper"

describe Genre do
  describe "Validations" do
    it "is invalid without a name" do
      genre = Genre.new(name: nil)
      refute genre.valid?
      assert_includes genre.errors[:name], "can't be blank"
    end

    it "is not valid with duplicated name" do
      existing_genre = genres(:drama)
      genre = Genre.new(name: existing_genre.name)

      refute genre.valid?
      assert_equal [ "has already been taken" ], genre.errors[:name]
    end
  end

  describe "Methods/callbacks" do
    it "Should set a slug when genre is saved" do
      genre = Genre.create!(name: "Anime")
      assert_equal "anime", genre.slug
    end

    it "Should to_param return the slug" do
    genre = genres(:drama)
    assert_equal "drama", genre.to_param
    end
  end
end
