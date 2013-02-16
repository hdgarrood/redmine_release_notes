class DoEverythingForVersion130 < ActiveRecord::Migration
  def up
    change_table :release_notes do |t|
      t.column :status,   :string,  :limit => 12
      t.change :text,     :text,    :limit => nil,  :null => true
    end

    add_index :release_notes, :status
    add_index :release_notes, :issue_id

    create_table :release_notes_formats do |t|
      t.string :name,         :null => false
      t.string :header,       :null => false
      t.string :each_issue,   :null => false
      t.string :start,        :null => false
      t.string :end,          :null => false
    end

    add_index :release_notes_formats, :name, :unique => true
  end

  def down
    # don't bother with changing the type of release_notes.text back
    remove_column :release_notes, :status
    remove_index :release_notes, :name => 'index_release_notes_on_issue_id'
    drop_table :release_notes_formats
  end
end
