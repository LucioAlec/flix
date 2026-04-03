class FavoritesController < ApplicationController
  before_action :require_signin
  before_action :set_movie

  def create
    favorite = @movie.favorites.find_or_initialize_by(user: current_user)

    if favorite.persisted? || favorite.save
      redirect_to @movie, notice: "Movie added to favorites."
    else
      redirect_to @movie, alert: "Could not add movie to favorites."
    end
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    favorite.destroy

    redirect_to @movie, notice: "Movie removed from favorites."
  end

  private

  def set_movie
    @movie = Movie.find_by!(slug: params[:movie_id])
  end
end
