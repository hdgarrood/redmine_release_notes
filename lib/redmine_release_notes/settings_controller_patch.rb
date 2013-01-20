# Copyright © 2012-2013 Harry Garrood
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
  module SettingsControllerPatch
    def self.patch(klass)
      unless @already_patched
        do_patch(klass)
        @already_patched = true
      end
    end

    private
    def self.do_patch(klass)
      klass.class_eval do
        # tells Rails to render the 'release notes settings' view instead of the
        # standard plugin settings view if the plugin we're looking at is the
        # release notes one
        def plugin_with_release_notes_patch
          plugin_without_release_notes_patch
          if request.get? && @plugin && @plugin.id == :redmine_release_notes
            render 'plugin_release_notes'
          end
        end

        alias_method_chain :plugin, :release_notes_patch
      end
    end
  end
end
