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

class ReleaseNotesController < ApplicationController
  unloadable

  before_filter :find_version, :only => [:generate]
  before_filter :find_project, :only => [:index]

  helper :projects

  def index
    @with_subprojects = params[:with_subprojects].nil? ?
      Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')

    @versions = @project.shared_versions || []
    @versions += @project.rolled_up_versions.visible if @with_subprojects
    @versions = @versions.uniq.sort

    # reject closed versions unless the user has specifically asked for them
    @versions.reject!(&:closed?) unless params[:closed]
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # we only expect this to be called with :format => :js
  def create
    @issue = Issue.find(params[:release_note][:issue_id])
    @release_note = @issue.build_release_note
    @release_note.text = params[:release_note][:text]

    if @release_note.save
      update_custom_field(params[:mark_completed])
    end

    render 'update'
  end

  # we only expect this to be called with :format => :js
  def update
    @issue = Issue.find(params[:release_note][:issue_id])
    @release_note = @issue.release_note
    @release_note.text = params[:release_note][:text]

    if @release_note.save
      update_custom_field(params[:mark_completed])
    end

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def destroy
    release_note = ReleaseNote.find(params[:id])
    issue = release_note.issue

    update_custom_field(false)

    release_note.destroy

    flash[:notice] = l(:notice_successful_delete)
    redirect_to issue
  end

  def generate
    # for project menu
    @project = @version.project

    @format = release_notes_format_from_params
    (render 'no_formats'; return) unless @format

    # for 'Also available in'
    @formats = ReleaseNotesFormat.select(:name).all

    @content = ReleaseNotesGenerator.new(@version, @format).generate

    if params[:raw]
      render :text => @content, :content_type => 'text/plain'
    elsif params[:download]
      send_data @content, :content_type => 'text/plain',
        :filename => "release-notes-#{@project.name}-version-#{@version.name}.txt"
    end
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

  def update_custom_field(completed)
    new_value = Setting.plugin_redmine_release_notes.
      fetch(completed ? :field_value_done : :field_value_todo)

    custom_value = @issue.release_notes_custom_value

    # TODO: Maybe it would be better to just go ahead and create one, instead
    # of telling the user to do it manually
    if !custom_value
      @release_note.errors.add(:base,
        t('release_notes.errors.failed_find_custom_value'))
      return
    end

    if custom_value.value != new_value
       old_value = custom_value.value
       custom_value.value = new_value

       if custom_value.save
         # record the change to the custom field
         journal = @issue.init_journal(User.current)
         journal.details << JournalDetail.new(
           :property => 'cf',
           :prop_key => custom_value.custom_field_id,
           :old_value => old_value,
           :value => new_value)
         if !journal.save
           @release_note.errors.add(:base,
             t('release_notes.errors.failed_save_journal_entry_html').html_safe)
         end
       else
        @release_note.errors.add(:base,
          t('release_notes.errors.failed_save_custom_value_html').html_safe)
       end
    end
  end

  def release_notes_format_from_params
    if (format_name = params[:release_notes_format])
      format = ReleaseNotesFormat.find_by_name(format_name)
    end

    if format.nil?
      id = Setting.plugin_redmine_release_notes[:default_generation_format_id]
      # dont raise RecordNotFound
      format = ReleaseNotesFormat.find_by_id(id)
    end

    # last resort -- just get the first one
    if format.nil?
      format = ReleaseNotesFormat.first
    end

    format
  end

end
