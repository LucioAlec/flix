class AddUniqueIndexToMoviesSlug < ActiveRecord::Migration[8.0]
  def change
    add_index :movies, :slug, unique: true
  end
end
