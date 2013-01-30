class ChangeReleaseNotesTextToTextType < ActiveRecord::Migration
  def change
    change_column :release_notes, :text, :text, :limit => 65536
  end
end
