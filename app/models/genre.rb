class Genre < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :charecterizations, dependent: :destroy
  has_many :movies, through: :charecterizations
end
