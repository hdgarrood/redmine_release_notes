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
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_show_description_bottom(context)
      issue, controller = context[:issue], context[:controller]

      if issue.eligible_for_release_notes?
        context[:release_note] = issue.release_note ||
          issue.build_release_note
        controller.render_to_string(
          { :partial =>
              'hooks/release_notes/view_issues_show_description_bottom',
            :locals => context }
        )
      else
        ""
      end
    end

    def view_versions_show_bottom(context)
      controller = context[:controller]

      controller.render_to_string(
        { :partial =>
            'hooks/release_notes/version_show_bottom',
          :locals => context }
      )
    end 
    def view_layouts_base_html_head(context)
        styles = stylesheet_link_tag('release_notes.css', :plugin => 'redmine_release_notes')
        styles
    end
  end
end
