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

        # issues whose release notes are done
        def self.release_notes_none
          none_value = Setting.plugin_redmine_release_notes[:field_value_not_required]
          joins_release_notes.
            where('custom_values.value' => none_value)
        end

        # issues whose release notes are invalid
        def self.release_notes_invalid
          todo_value = Setting.plugin_redmine_release_notes[:field_value_todo]
          done_value = Setting.plugin_redmine_release_notes[:field_value_done]
          none_value = Setting.plugin_redmine_release_notes[:field_value_not_required] 

          joins_release_notes.
            where('custom_values.value not in (?)', [done_value, todo_value,none_value])
        end

        def self.release_notes_no_cf_defined
          includes(:custom_values).where(no_cf_defined_condition) 
        end

        # issues where CF is set to 'none' OR for which custom field is not defined
        def self.release_notes_not_required
          cf_id = Setting.plugin_redmine_release_notes[:issue_custom_field_id].to_i
          none_value = Setting.plugin_redmine_release_notes[:field_value_not_required]
 
          conditions = "( custom_values.custom_field_id = #{cf_id}"
          conditions << " AND custom_values.value = '#{connection.quote_string(none_value)}' )"

          includes(:custom_values).where( conditions + " OR " + no_cf_defined_condition ) 
        end

        # issues which don't have a custom value for release notes
	# now it doesn't contain issues where cf is not defined
	# - those issues are qualified under release_notes_not_required
        def self.release_notes_custom_value_nil
          conditions = "( (custom_values.value IS NULL"
          conditions << " OR custom_values.value = '') )"

          joins_release_notes.where(conditions)
        end

        # issues which have the release notes custom field value set to 'done'
        # but no release notes
        def self.done_but_release_notes_nil
          conditions = "NOT EXISTS ("
          conditions << "SELECT 1 FROM release_notes"
          conditions << " WHERE issue_id = issues.id"
          conditions << ")"
          release_notes_done.where(conditions)
        end

        # can this issue have release notes?
        # true if the issue has the configured custom field for release notes
        def eligible_for_release_notes?
          cf_id = Setting.
            plugin_redmine_release_notes[:issue_custom_field_id].to_i
          available_custom_fields.include?(CustomField.find(cf_id))
        rescue ActiveRecord::RecordNotFound
          false
        end

        def release_notes_done?
           cf = release_notes_custom_value
           done_value = Setting.plugin_redmine_release_notes[:field_value_done]
           cf.value == done_value unless cf.nil?
        rescue ActiveRecord::RecordNotFound
           false
        end

        # returns the CustomValue which describes the release notes status for
        # this issue
        def release_notes_custom_value
          cf_id = Setting.
            plugin_redmine_release_notes[:issue_custom_field_id].to_i
          custom_values.find_by_custom_field_id(cf_id)
        end

        private
        def self.joins_release_notes
          custom_field_id = Setting.
            plugin_redmine_release_notes[:issue_custom_field_id]
          joins(:custom_values).
            where('custom_values.custom_field_id' => custom_field_id)
        end

	def self.no_cf_defined_condition
          cf_id = Setting.
            plugin_redmine_release_notes[:issue_custom_field_id].to_i

          conditions_b = "NOT EXISTS ("
          conditions_b << "SELECT 1 FROM custom_values"
          conditions_b << " WHERE custom_values.customized_type = 'Issue'"
          conditions_b << " AND custom_values.custom_field_id = #{cf_id}"
          conditions_b << " AND custom_values.customized_id = issues.id"
          conditions_b << ") "
       	
	  conditions_b
	end 
      end
    end
  end
end
