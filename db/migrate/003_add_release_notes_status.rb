class AddReleaseNotesStatus < ActiveRecord::Migration
  def change
    add_column :release_notes, :status, :integer
    add_index :release_notes, :status
  end
end
