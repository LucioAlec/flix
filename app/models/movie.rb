class Movie < ApplicationRecord
  has_many :reviews, dependent: :destroy

  validates :title, :released_on, :duration, presence: true
  validates :description, length: { minimum: 25 }
  validates :total_gross, numericality: { greater_than_or_equal_to: 0 }
  validates :image_file_name, format: {
                                        with: /\A[\w.\-]+\.(jpg|png)\z/i,
                                        message: "must be a JPG or PNG image"
                                      }
  RATINGS = %w[G PG PG-13 R NC-17]
  validates :rating, inclusion: { in: RATINGS }


  def self.released
    where("released_on > ?", Time.now).order(released_on: :desc)
  end

  def flop?
    unless reviews.count >= 0 && average_stars >= 4
      (total_gross.blank? || total_gross < 225_000_000)
    end
    # total_gross.blank? || total_gross < 225_000_000 && average(:stars) >= 4 && reviews.count
  end

  def self.hits
    where("total_gross >= 300_000_000").order(total_gross: :desc).limit(3)
  end

  def self.flops
    # where("total_gross <= 225_000_000").order(total_gross:).limit(3)
    where("total_gross < 22500000").order(total_gross: :asc)
    # where("total_gross <= ?", 225_000_000).order(total_gross: :desc).limit(3)
  end

  def self.recently_added
    order("created_at desc").limit(3)
  end

  def average_stars
    reviews.average(:stars) || 0.0
  end
end
