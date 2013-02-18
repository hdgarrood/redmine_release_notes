# Copyright (C) 2012-2013 Harry Garrood
# This file is a part of redmine_release_notes.

# redmine_release_notes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.

# redmine_release_notes is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.

# You should have received a copy of the GNU General Public License along with
# redmine_release_notes. If not, see <http://www.gnu.org/licenses/>.

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
