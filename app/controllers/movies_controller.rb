class MoviesController < ApplicationController
  before_action :require_signin, except: [ :index, :show ]
  before_action :require_admin, except: [ :index, :show ]
  before_action :set_movie, only: %i[show edit update destroy]
  def index
      @movies = Movie.public_send(movies_filter)
  end

  def show
  @fans = @movie.fans
  @genres = @movie.genres.order(:name)
    if current_user
      @favorite = current_user.favorites.find_by(movie_id: @movie.id)
    end
  end

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
      flash.now[:alert] = "Movie unsuccessfully created!"
      render :new, status: :unprocessable_entity
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
               :director, :duration, :image_file_name, :released_on, :total_gross, genre_ids: [])
  end

  def set_movie
    @movie = Movie.find_by!(slug: params[:id])
  end

  def movies_filter
    allowed = %w[released upcoming recent hits flops]
    filter = params[:filter]

    if filter.in?(allowed)
      filter
    else
    :released
    end
  end
end
