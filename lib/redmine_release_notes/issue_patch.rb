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

module RedmineReleaseNotes
  module IssuePatch
    def self.perform
      Issue.class_eval do
        has_one :release_note, :dependent => :destroy

        # NB: the release_notes_* scopes will not return issues which don't
        # have a value for the issue custom field.
        
        # all the issues which need release notes (including ones which have
        # them already)
        def self.release_notes_required
          done_value = Setting.plugin_redmine_release_notes[:field_value_done]
          todo_value = Setting.plugin_redmine_release_notes[:field_value_todo]
          joins_release_notes.
            where('custom_values.value' => [done_value, todo_value])
        end

        # issues which still need release notes
        def self.release_notes_todo
          todo_value = Setting.plugin_redmine_release_notes[:field_value_todo]
          joins_release_notes.
            where('custom_values.value' => todo_value)
        end

        # issues whose release notes are done
        def self.release_notes_done
          done_value = Setting.plugin_redmine_release_notes[:field_value_done]
          joins_release_notes.
            where('custom_values.value' => done_value)
        end

        # can this issue have release notes?
        # true if the issue has the configured custom field for release notes
        def eligible_for_release_notes?
          cf_id = Setting.plugin_redmine_release_notes[:issue_custom_field_id]
          available_custom_fields.include?(CustomField.find(cf_id))
        rescue ActiveRecord::RecordNotFound
          false
        end

        private
        def joins_release_notes
          custom_field_id = Setting.
            plugin_redmine_release_notes[:issue_custom_field_id]
          joins(:custom_values).
            where('custom_values.custom_field_id' => custom_field_id)
        end
      end
    end
  end
end
