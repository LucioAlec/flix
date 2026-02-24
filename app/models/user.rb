class User < ApplicationRecord
  before_save :set_slug
  before_save :format_username
  before_save :format_email
  has_many :reviews, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_movies, through: :favorites, source: :movie
  has_secure_password

  validates :name, presence: true
  validates :slug, uniqueness: true

  validates :email, format: { with: /\A#{URI::MailTo::EMAIL_REGEXP}\z/ }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 10, allow_blank: true }

  validates :username, presence: true, format: { with: /\A[A-Z0-9]+\z/i }, uniqueness: { case_sensitive: false }

  scope :by_name, -> { order(:name) }
  scope :not_admins, -> { by_name.where(admin: false) }

  def gravatar_id
    Digest::MD5.hexdigest(email.downcase)
  end

  def format_username
    self.username = username.downcase
  end
  def format_email
    self.email = email.downcase
  end

  def to_param
    slug
  end

  private

  def set_slug
    self.slug= username.parameterize
  end
end
