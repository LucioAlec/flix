class ReviewsController < ApplicationController
  before_action :require_signin
  before_action :set_movie
  before_action :set_review, only: [ :edit, :update, :destroy ]
  before_action :require_owner_or_admin, only: [ :edit, :update, :destroy ]


  def index
    @reviews = @movie.reviews
  end

  def new
    @review = @movie.reviews.new
  end

  def create
    @review = @movie.reviews.new(review_params)
    @review.user = current_user

    if @review.save
      redirect_to movie_reviews_path(@movie),
                  notice: "Thanks for your review!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to movie_reviews_path(@movie), notice: "Review updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to movie_reviews_path(@movie), status: :see_other, notice: "Review deleted!"
  end


  private

  def review_params
    params.require(:review).permit(:comment, :stars)
  end

  def set_movie
    @movie = Movie.find_by!(slug: params[:movie_id])
  end

  def set_review
    @review = @movie.reviews.find(params[:id])
  end

  def require_owner_or_admin
    unless current_user_admin? || current_user?(@review.user)
      redirect_to movie_reviews_path(@movie), alert: "You're not authorized to do that."
    end
  end
end
