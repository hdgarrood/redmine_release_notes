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

class ReleaseNote < ActiveRecord::Base
  unloadable
  belongs_to :issue

  # the trackers which can have release notes
  def self.enabled_tracker_ids
    (Setting.plugin_redmine_release_notes[:enabled_tracker_ids] || []).
      map(&:to_i).
      reject {|i| i == 0}
  end

  # the projects which can have release notes
  def self.enabled_project_ids
    (EnabledModule.where(:name => 'release_notes').select('project_id') || []).
      map(&:project_id).
      map(&:to_i)
  end

  attr_accessible :text

  validates_presence_of :issue
  validates_presence_of :text
end
