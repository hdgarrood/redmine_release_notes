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
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_show_description_bottom(context = {})
      cf = CustomField.find(
        Setting['plugin_redmine_release_notes']['issue_required_field_id'])

      if context[:project].module_enabled? :release_notes &&
         context[:issue].tracker.custom_fields.include?(cf)
        context[:controller].send(:render_to_string,
          { :partial =>
              'hooks/release_notes/view_issues_show_description_bottom',
            :locals => context })
      else
        ""
      end
    rescue ActiveRecord::RecordNotFound
      context[:controller].send(:render_to_string,
        { :partial =>
            'hooks/release_notes/failed_find_issue_custom_field',
          :locals => context })
    end
  end
end
