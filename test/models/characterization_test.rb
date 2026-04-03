require "test_helper"

class CharacterizationTest < ActiveSupport::TestCase
   test "Should is valid when has movie and genre" do
     characterization = Characterization.new(
      movie: movies(:one),
      genre: genres(:one)
     )

     assert characterization.valid?
   end

   test "Should is not valid without movie" do
     characterization = Characterization.new(
      movie: nil,
      genre: genres(:one)
     )

     refute characterization.valid?
     assert_includes characterization.errors[:movie], "must exist"
   end

   test "Should is not valid without genre" do
     characterization = Characterization.new(
      movie: movies(:one),
      genre: nil
     )

     refute characterization.valid?
     assert_includes characterization.errors[:genre], "must exist"
   end
end
