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
      if context[:issue].eligible_for_release_notes?
        context[:release_notes] = context[:issue].release_note ||
          context[:issue].create_release_note
        context[:controller].send(:render_to_string,
          { :partial =>
              'hooks/release_notes/view_issues_show_description_bottom',
            :locals => context })
      else
        ""
      end
    end
  end
end
