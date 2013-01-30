class MakeReleaseNotesTextNullable < ActiveRecord::Migration
  def change
    change_column :release_notes, :text, :text, :null => true
  end
end
