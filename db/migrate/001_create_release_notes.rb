class CreateReleaseNotes < ActiveRecord::Migration
  def self.up
    create_table :release_notes do |t|
      t.column :id, :integer
      t.column :issue_id, :integer
      t.column :text, :string
    end
  end

  def self.down
    drop_table :release_notes
  end
end
