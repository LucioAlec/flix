class RenameCharecterizationsToCharacterization < ActiveRecord::Migration[8.0]
  def change
    rename_table :charecterizations, :characterizations
  end
end
