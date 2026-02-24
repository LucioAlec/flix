class AddUniqueIndexToUsersSlug < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :slug, unique: true
  end
end
