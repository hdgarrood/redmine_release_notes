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

class DoEverythingForVersion131 < ActiveRecord::Migration
  def up
    # remove release_notes.status => now a custom field
    remove_column :release_notes, :status

    # don't allow nulls in release_notes.text
    change_table :release_notes do |t|
      t.change :text, :text, :null => false
    end
  end

  def down
    change_table :release_notes do |t|
      t.column :status,   :string,  :limit => 12
      t.change :text,     :text,    :limit => nil,  :null => true
    end

    add_index :release_notes, :status
  end
end
