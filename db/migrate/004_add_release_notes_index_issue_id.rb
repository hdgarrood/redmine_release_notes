class AddReleaseNotesIndexIssueId < ActiveRecord::Migration
  def change
    add_index :release_notes, :issue_id
  end
end
