class MoviesController < ApplicationController
  before_action :set_movie, only: %i[show edit update destroy]
  def index
  @movies = Movie.all # ["Iron Man", "Superman", "Spider-Man", "Batman"]
  end

  def show ; end

  def edit ; end

  def update
    if @movie.update(movie_params)
    redirect_to @movie, notice: "Movie successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    if @movie.save
    redirect_to @movie
    else
      render :new, status: :unprocessable_entity, notice: "Movie successfully created!"
    end
  end

  def destroy
    @movie.destroy
    redirect_to movies_url, status: :see_other, danger: "Movie successfully deleted!"
  end


  private
  def movie_params
    params.require(:movie)
      .permit(:title, :description, :rating,
               :director, :duration, :image_file_name, :released_on, :total_gross)
  end

  def set_movie
    @movie = Movie.find(params[:id])
  end
end
