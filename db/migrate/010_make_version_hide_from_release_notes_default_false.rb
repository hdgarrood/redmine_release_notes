class MakeVersionHideFromReleaseNotesDefaultFalse < ActiveRecord::Migration
  def change
    change_table :versions do |t|
      t.change :hide_from_release_notes, :boolean, :default => false
    end
  end
end
