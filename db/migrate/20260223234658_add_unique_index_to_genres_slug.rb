class AddUniqueIndexToGenresSlug < ActiveRecord::Migration[8.0]
  def change
    add_index :genres, :slug, unique: true
  end
end
