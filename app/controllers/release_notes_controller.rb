# Copyright (C) 2012  Harry Garrood
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

class ReleaseNotesController < ApplicationController
  unloadable
  
  before_filter :find_version, :only => [:generate, :hide_version]
  before_filter :find_project, :only => [:index]
  
  helper :projects
  
  def index
    @with_subprojects = params[:with_subprojects].nil? ?
      Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')

    @versions = @project.shared_versions || []
    @versions += @project.rolled_up_versions.visible if @with_subprojects
    @versions = @versions.uniq.sort

    # reject hidden versions unless the user has specifically asked for them
    # todo: check for hidden versions
    @versions.reject!(&:hide_from_release_notes) unless params[:hidden]
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  # we only expect this to be called with :format => :js
  def update
    @release_notes = ReleaseNote.find(params[:id])
    @release_notes.update_attributes(params[:release_note])
    @release_notes.save
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def destroy
    release_note = ReleaseNote.find(params[:id])
    issue = release_note.issue
    release_note.destroy

    flash[:notice] = l(:notice_successful_delete)
    redirect_to issue
  end
  
  def generate
    # for project menu
    @project = @version.project

    # for 'Also available in'
    @formats = ReleaseNotesFormat.all
    @format = ReleaseNotesFormat.find_by_name(params[:release_notes_format]) ||
      @formats.first # todo: use default from settings

    @content = ReleaseNotesGenerator.new(@version, @format).generate

    if params[:raw]
      render :text => @content, :content_type => 'text/plain'
    elsif params[:download]
      send_data @content, :content_type => 'text/plain',
        :filename => "release-notes-#{@project.name}-version-#{@version.name}.txt"
    end
  end
  
  def hide_version
    @version.hide_from_release_notes = true
    if @version.save
      flash[:notice] = t(:notice_successful_update)
    else
      # TODO: a helpful error message would be better here
      render_404
    end

    redirect_to release_notes_path(:project_id => @version.project.identifier)
  end
  
 private  
  def find_version
    @version = Version.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
