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
  module SettingsControllerPatch
    def self.perform
      SettingsController.class_eval do
        helper 'release_notes_settings'

        # tells Rails to render the 'release notes settings' view instead of the
        # standard plugin settings view if the plugin we're looking at is the
        # release notes one
        def plugin_with_release_notes_patch
          if params[:id] == 'redmine_release_notes'
            plugin_redmine_release_notes
          else
            plugin_without_release_notes_patch
          end
        end

        def plugin_redmine_release_notes
          if request.get?
            @settings = Setting.plugin_redmine_release_notes
            @formats = ReleaseNotesFormat.all
            render 'plugin_release_notes'
          elsif request.post?
            # if params looks ok, update settings in the db
            if (params[:settings] &&
              params[:settings][:default_generation_format_id].to_i > 0)
              plugin_without_release_notes_patch
            else
              # otherwise just GET the settings again
              redirect_to plugin_settings_path(:id => 'redmine_release_notes')
            end
          else
            render_404
          end
        end
        alias_method :plugin_without_release_notes_patch, :plugin
        alias_method :plugin, :plugin_with_release_notes_patch
      end
    end
  end
end
