class AddUniqueIndexToFavorites < ActiveRecord::Migration[8.0]
  def change
    add_index :favorites, [ :user_id, :movie_id ], unique: true
  end
end
