require "test_helper"

describe User do
  def user
    @user ||= users(:alec) # let(:user) { movies(:alec)} #gem minitest-spec-rails
  end

  describe "Validations" do
    it "Should authenticates with the correct password" do
    assert_equal user, user.authenticate("password123")
    end

    it "Should not authenticate with an incorrect password" do
      refute user.authenticate("wrongwrongwrong")
    end

    it "Should be not valid when email is incorret" do
      user.email = "luexamplecom"
      refute user.valid?
    end

    it "Should not valid duplicated email" do
    existing_user = user

    other_user_same_email = User.new(
        name: "Other",
        username: "otheruser",
        email: "alec@example.com",
        password: "1234567890",
        password_confirmation: "1234567890"
    )

      refute other_user_same_email.valid?
      assert_equal [ "has already been taken" ], other_user_same_email.errors[:email]
    end

    it "shouldn't valid duplicated slug" do
      existing_user = user
      other_user = User.new(
        name: "Other",
        username: "otheruser",
        email: "a@a.com",
        password: "1234567890",
        password_confirmation: "1234567890"
        )
        other_user.slug = existing_user.slug

      refute other_user.valid?
      assert_equal [ "has already been taken" ], other_user.errors[:slug]
    end

    it "Shouldn't valid duplicated username" do
      existing_user = user

      other_user_same_username = User.new(
        name: "Other",
        username: "alec",
        email: "a@a.com",
        password: "1234567890",
        password_confirmation: "1234567890"
      )

      refute other_user_same_username.valid?
      assert_equal [ "has already been taken" ], other_user_same_username.errors[:username]
    end

    it "should is not valid password with less than 10 caracteres" do
      user.password = "123456789"
      user.password_confirmation= "123456789"
      refute user.valid?
    end


    it "should is not valid with password blank" do
      user.password = ""
      user.password_confirmation = ""

      refute user.valid?
    end
  end

  describe "Scopes" do
    it "Should order users by name" do
      ordered_users = User.by_name

      assert_equal [ "Alec", "Balec", "Lucio" ], ordered_users.pluck(:name)
    end

    it "Should order not admin users by name" do
      result = User.not_admins

      assert_equal [ "Balec", "Lucio" ], result.pluck(:name)
    end
  end

  describe "methods/callbacks" do
    it "Should create gravatar_id value when user is created" do
      user = User.create!(
        name: "Lucio Ferreira",
        username: "Alec34",
        email: "lucioalec@example.com",
        password: "1234567890",
        password_confirmation: "1234567890"
      )
      expected = Digest::MD5.hexdigest("lucioalec@example.com")
      assert_equal expected, user.gravatar_id
    end

    it "Should format username to downcase when save user with callback" do
      user = User.create!(
        name: "TESTE",
        username: "tEsTe",
        email: "test@gamil.com",
        password: "1234567890",
        password_confirmation: "1234567890"
      )
      assert_equal "teste", user.username
    end

    it "Should format email to downcase when save user with callback" do
      user = User.create!(
        name: "Nog",
        username: "nogf",
        email: "TET@gamil.com",
        password: "1234567890",
        password_confirmation: "1234567890"
      )
      assert_equal "tet@gamil.com", user.email
    end

    it "Should to param returns the slug when save user" do
      assert_equal user.slug, user.to_param
    end

    it "Should set a slug when user is saved" do
      assert user.slug.present?
      assert_equal "alec", user.slug
    end
  end
end
