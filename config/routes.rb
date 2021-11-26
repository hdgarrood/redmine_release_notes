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

RedmineApp::Application.routes.draw do
  get '/projects/:project_id/release_notes',
    :to => 'release_notes#index',
    :as => :release_notes_overview

  resources :release_notes,
    :only => [:create, :update, :destroy]

  get "/versions/:id/generate_release_notes",
    :to => "release_notes#generate",
    :as => :generate_release_notes

  get "/issues/:issue_id/release_note",
    :to => 'release_notes#view',
    :as => :release_note_view,
    defaults: { format: 'json' }


  patch 'release_notes_formats/preview',
    :to => 'release_notes_formats#preview',
    :as => :preview_release_notes_format

  resources :release_notes_formats,
    :except => [:index, :show]

  get 'settings/plugin/redmine_release_notes?tab=formats',
    :to => 'settings#plugin',
    :as => :release_notes_formats_tab
end
