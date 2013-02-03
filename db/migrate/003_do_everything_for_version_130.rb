class DoEverythingForVersion130 < ActiveRecord::Migration
  def up
    change_table :release_notes do |t|
      t.column :status,   :string,  :limit => 12
      t.change :text,     :text,    :limit => nil,  :null => true
    end

    change_table :versions do |t|
      t.boolean :hide_from_release_notes, :default => false, :null => false
    end

    add_index :release_notes, :status
    add_index :release_notes, :issue_id
  end

  def down
    # don't bother with changing the type of release_notes.text back, or
    # dropping the indices -- if we're migrating down it's probably because
    # the plugin is being uninstalled, so that stuff gets taken care of when
    # the table is dropped
    remove_column :release_notes, :status
    remove_column :versions, :hide_from_release_notes
  end
end
