class AddReleaseNotesNulls < ActiveRecord::Migration
  def change
    change_table :release_notes do |t|
      t.change :status, :integer, :null => false
      t.change :issue_id, :integer, :null => false
      t.change :text, :string, :null => false
    end
  end
end
