class IncreaseReleaseNotesLengthLimit < ActiveRecord::Migration
  def self.up
    change_column :release_notes, :text, :string, :limit => 2000
  end

  def self.down
    change_column :release_notes, :text, :string, :limit => 254
  end
end
