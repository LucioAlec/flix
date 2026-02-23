class GenresController < ApplicationController
  before_action :require_admin, except: [ :show, :index ]
  before_action :set_genre, only: [ :edit, :show, :update, :destroy ]


  def index
    @genres = Genre.all
  end

  def show
    @movies = @genre.movies.order(:title)
  end

  def new
    @genre = Genre.new
  end

  def create
    @genre = Genre.new(genre_params)
    if @genre.save
      redirect_to @genre, notice: "Genre created!"
    else
      flash.now[:alert] = "Genre Uncessufully created."
      render :new, status: :unprocessable_entity
    end
  end

  def edit ; end

  def update
    if @genre.update(genre_params)
      redirect_to @genre, notice: "Genre successfully updated"
    else
      flash.now[:alert] = "Genre Unccessfully updated"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @genre.destroy
    redirect_to genres_url, status: :see_other, notice: "Genre successfully deleted!"
  end

  private
    def genre_params
      params.require(:genre).permit(:name)
    end

    def set_genre
    @genre = Genre.find_by!(slug: params[:id])
    end
end
