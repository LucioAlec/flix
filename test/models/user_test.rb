require "test_helper"

describe User do
  def setup
  @user = User.new(
    name: "Lucio Ferreira",
    username: "Alec34",
    email: "luciOALec@example.com",
    password: "1234567890",
    password_confirmation: "1234567890",
    admin: true
    )
  end

  describe "Validations" do
    test "is valid with valid attributes" do
      assert @user.valid?
    end

    test "fixture users are valid?" do
      assert users(:one).valid?
      assert users(:two).valid?
    end

    test "authenticates with the correct password" do
    @user.save

    assert_equal @user, @user.authenticate("1234567890")
    end

    test "Should not authenticate with an incorrect password" do
      @user.save

      refute @user.authenticate("wrongwrongwrong")
    end

    test "is not valid with email nil" do
      @user.email = nil
      refute @user.valid?
    end

    test "should be not valid when email is incorret" do
      @user.email = "luexamplecom"
      refute @user.valid?
    end

    test "Is not valid duplicated email" do
    existing_user= @user
    existing_user.save

    other_user_same_email = User.new(
        name: "Other",
        username: "otheruser",
        email: "lucioalec@example.com",
        password: "1234567890",
        password_confirmation: "1234567890"
    )

      refute other_user_same_email.valid?
      assert_equal [ "has already been taken" ], other_user_same_email.errors[:email]
    end

    test "should is not valid with name nil" do
      @user.name = nil
      refute @user.valid?
    end

    test "shouldn't valid duplicated slug" do
      existing_user = @user
      existing_user.save
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

    test "Shouldn't valid duplicated username" do
      existing_user = @user
      existing_user.save

      other_user_same_username = User.new(
        name: "Other",
        username: "Alec34",
        email: "a@a.com",
        password: "1234567890",
        password_confirmation: "1234567890"
      )

      refute other_user_same_username.valid?
      assert_equal [ "has already been taken" ], other_user_same_username.errors[:username]
    end

    test "should is not valid with username nil" do
      @user.username = nil
      refute @user.valid?
    end

    test "should be not valid when username is out of the format" do
      @user.username = "Spacial Rend┼"
      refute @user.valid?
    end

    test "should is not valid password with less than 10 caracteres" do
      @user.password = "123456789"
      @user.password_confirmation= "123456789"
      refute @user.valid?
    end

    test "should is not valid with password nil" do
      @user.password = nil
      refute @user.valid?
    end

    test "should is not valid with password blank" do
      @user.password = ""
      @user.password_confirmation = ""

      refute @user.valid?
    end
  end

  describe "Scopes" do
    test "Should order users by name" do
      ordered_users = User.by_name

      assert_equal [ users(:two), users(:one) ], ordered_users
    end

    test "Should order not admin users by name" do
        aalec = User.create!(
          name: "Alec",
          username: "Alec34",
          email: "luciOALec@example.com",
          password: "1234567890",
          password_confirmation: "1234567890",
          admin: false
        )
        balec = User.create!(
          name: "Balec",
          username: "BAlec34",
          email: "balec@example.com",
          password: "1234567890",
          password_confirmation: "1234567890",
          admin: true
        )
        calec = User.create!(
          name: "Calec",
          username: "CAlec34",
          email: "calec@example.com",
          password: "1234567890",
          password_confirmation: "1234567890",
          admin: false
        )

      ordered_users = User.not_admins

      assert_equal [ "Alec", "Calec", "a" ], ordered_users.pluck(:name)
    end
  end

  describe "methods/callbacks" do
    test "Should create gravatar_id value when user is created" do
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

    test "Should format username to downcase when save user with callback" do
      @user.save!
      assert_equal "alec34", @user.username
    end

    test "Should format email to downcase when save user with callback" do
      @user.save!
      assert_equal "lucioalec@example.com", @user.email
    end

    test "Should to param returns the slug when save user" do
      @user.save
      user = @user.to_param
      assert_equal "alec34", user
    end

    test "Should set a slug when user is saved" do
      @user.save
      user = @user.slug
      assert_equal "alec34", user
    end
  end
end
