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

        # all the issues which need release notes (including ones which have
        # them already)
        def self.release_notes_required
          with_release_notes.where('custom_values.value IN (?,?)',
            Setting.plugin_redmine_release_notes['field_value_todo'],
            Setting.plugin_redmine_release_notes['field_value_done'])
        end

        # issues which still need release notes
        def self.release_notes_to_be_done
          with_release_notes.where('custom_values.value = ?',
            Setting.plugin_redmine_release_notes['field_value_todo'])
        end

        # issues whose release notes are done
        def self.release_notes_completed
          with_release_notes.where('custom_values.value = ?',
            Setting.plugin_redmine_release_notes['field_value_done'])
        end

        # are the release notes complete for a particular issue
        def release_notes_completed?
          setting = Setting.plugin_redmine_release_notes
          custom_field_id = setting['issue_required_field_id']
          cv = self.custom_values.find_by_custom_field_id(custom_field_id)
          cv.value == setting['field_value_done']
        end

        private
        # joins issues with custom values so that the result set has one row
        # per issue, and the value of the release notes custom field for that
        # issue is given by 'custom_values.value'
        def self.with_release_notes
          custom_field_id = Setting.plugin_redmine_release_notes['issue_required_field_id']
          joins(:custom_values).
            where('custom_values.custom_field_id = ?', custom_field_id)
        end
      end
    end
  end
end
