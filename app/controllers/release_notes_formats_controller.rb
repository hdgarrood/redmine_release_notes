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

class ReleaseNotesFormatsController < ApplicationController
  layout 'admin'
  before_filter :require_admin

  def new
    @format = ReleaseNotesFormat.new
  end

  def create
    params.permit!
    @format = ReleaseNotesFormat.new(params[:release_notes_format])
    if @format.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to release_notes_formats_tab_path
    else
      render 'new'
    end
  end

  def edit
    params.permit!
    @format = ReleaseNotesFormat.find(params[:id])
  end

  def update
    params.permit!
    @format = ReleaseNotesFormat.find(params[:id])
    if @format.update_attributes(params[:release_notes_format])
      flash[:notice] = l(:notice_successful_update)
      redirect_to release_notes_formats_tab_path
    else
      render 'edit'
    end
  end

  def destroy
    params.permit!
    @format = ReleaseNotesFormat.find(params[:id])
    @format.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to release_notes_formats_tab_path
  end

  # we only expect this with :format => :js
  def preview
    params.permit!
    format = ReleaseNotesFormat.new(params[:release_notes_format])
    version = ReleaseNotesGenerator::MockVersion.new
    @text = ReleaseNotesGenerator.new(version, format).generate
    render :text => @text
  end
end
