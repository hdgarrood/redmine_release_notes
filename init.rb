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

require 'redmine'
require 'redmine_release_notes/hooks'

# Patches to the Redmine core.
require_dependency 'issue'
require_dependency 'settings_controller'

ActionDispatch::Callbacks.to_prepare do
  RedmineReleaseNotes::IssuePatch.patch(Issue)
  RedmineReleaseNotes::SettingsControllerPatch.patch(SettingsController)
end

Redmine::Plugin.register :redmine_release_notes do
  name 'Redmine release notes plugin'
  author 'Harry Garrood'
  description 'A plugin for managing release notes.'
  version '1.2.1-pre'
  author_url 'https://github.com/hdgarrood'
  requires_redmine :version_or_higher => '2.0.0'

  settings :default => {
      'issue_required_field_id' => 0,
      'field_value_done' => 'Done',
      'field_value_todo' => 'Todo',
      'field_value_not_required' => 'No',
      'version_generated_field_id' => 0,
      'default_generation_format' => 'HTML'
    }, :partial => 'not_blank' # this won't be used, but can't be blank
  
  project_module :release_notes do
    permission :release_notes,
      { :release_notes =>
        [:index, :new, :generate, :mark_version_as_generated] },
      :public => true
  end
  
  menu :project_menu,
    :release_notes,
    { :controller => 'release_notes', :action => 'index' },
    :caption => :Release_notes,
    :param => :project_id
end
