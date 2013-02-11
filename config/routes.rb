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

RedmineApp::Application.routes.draw do
  resources :release_notes,
    :path => '/projects/:project_id/release_notes',
    :only => [:index]

  resources :release_notes,
    :only => [:update]

  get "/versions/:id/generate_release_notes",
    :to => "release_notes#generate",
    :as => :generate_release_notes

  post "/versions/:id/hide_from_release_notes",
    :to => "release_notes#hide_version",
    :as => :hide_version_from_release_notes

  resources :release_notes_formats,
    :except => [:index, :show]
end
