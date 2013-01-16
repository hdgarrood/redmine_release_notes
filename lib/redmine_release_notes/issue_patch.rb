# Patches Redmine's issues dynamically.
# Adds a relationship - an issue has one release note
# Adds methods for counting required and completed release notes for a version

# Copyright © 2012  Harry Garrood
# This file is a part of redmine_release_notes.

# redmine_release_notes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# redmine_release_notes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with redmine_release_notes.  If not, see <http://www.gnu.org/licenses/>.

module RedmineReleaseNotes
  module IssuePatch
    def self.patch(issue_class)
      unless @issue_class_patched
        do_patch(issue_class)
        @issue_class_patched = true
      end
    end

    private
    def self.do_patch(issue_class)
      issue_class.class_eval do
        has_one :release_note, :dependent => :destroy
        validates_associated :release_note

        # all the issues wanting release notes for a particular version
        def self.release_notes_required(version)
          release_notes_to_be_done(version).release_notes_completed(version)
        end

        # all the issues which still need release notes for a version
        def self.release_notes_to_be_done(version)
          release_notes_for(version).
            where('custom_values.value = ?',
              Setting['plugin_redmine_release_notes']['field_value_to_be_done'])
        end

        # all the issues whose release notes are done for a version
        def self.release_notes_completed(version)
          release_notes_for(version).
            where('custom_values.value = ?',
              Setting['plugin_redmine_release_notes']['field_value_done'])
        end

        private
        def self.release_notes_for(version)
          joins(:custom_values).
            where('custom_values.custom_field_id = ?',
              Setting['plugin_redmine_release_notes']['issue_required_field_id'])
            where('fixed_version_id = ?', version.id)
        end
      end
    end
  end
end
