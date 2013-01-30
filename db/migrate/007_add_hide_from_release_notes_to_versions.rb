class AddHideFromReleaseNotesToVersions < ActiveRecord::Migration
  def change
    change_table :versions do |t|
      t.boolean :hide_from_release_notes, :null => :false
    end
  end
end
