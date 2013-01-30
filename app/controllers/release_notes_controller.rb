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

require 'yaml'

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
  
  def show
    release_note = ReleaseNote.find(params[:id])
    redirect_to release_note.issue
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def new
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
    
    @release_note = ReleaseNote.new
    @release_note.issue = @issue
    @release_notes_completed = false
    render :action => 'edit'
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def edit
    @release_note = ReleaseNote.find(params[:id])
    @issue = @release_note.issue
    @project = @issue.project
    @release_notes_completed = @release_note.completed?
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def create
    @release_note = ReleaseNote.create(params[:release_note])
    @issue = @release_note.issue

    if @issue.save
      flash[:notice] = l(:notice_successful_create)
      update_custom_field(params[:mark_complete])
      redirect_to @issue
    else
      error_str = format_release_note_errors(@issue, l(:label_issue))
      flash.now[:error] = error_str
      render :action => 'edit', :id => params[:release_note][:id]
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def update
    @release_note = ReleaseNote.find(params[:id])
    @release_note.text = params[:release_note][:text]

    if @release_note.save
      flash[:notice] = l(:notice_successful_update)
    else
      error_str = format_release_note_errors(@release_note, l(:release_note))
      flash[:error] = error_str
      redirect_to edit_release_note_path(@release_note)
      return
    end
    
    update_custom_field(params[:mark_complete])
    redirect_to @release_note.issue
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
    @project = @version.project
    @formats = ['todo']
    @format = params[:release_notes_format]
    if @formats[@format].nil? or @formats[@format].empty?
      @format = Setting.plugin_redmine_release_notes['default_generation_format']
    end

    if params[:raw]
      content = view_context.generate_release_notes_header(@version.id, @formats[@format])
      content << "\n"
      content << view_context.generate_release_notes(@version.id, @formats[@format])
      render :text => content,
             :content_type => 'text/plain'
    end
  end
  
  def mark_version_as_generated
    if request.post?
      @project = @version.project
      generated_field_id = CustomField.find_by_name(ReleaseNotesHelper::CONFIG['version_generated_field'])
      custom_value = @version.custom_values.find_or_initialize_by_custom_field_id(generated_field_id)
      custom_value.value = 1
      if custom_value.save
        flash.now[:notice] = l(:notice_successful_update)
      else
        error_str = format_release_note_errors(custom_value, l(:label_custom_field))
        flash.now[:error] = error_str
      end
    else
      render_403
    end
  rescue ActiveRecord::RecordNotFound
    flash.now[:error] = l(:failed_find_custom_field, :field => ReleaseNotesHelper::CONFIG['version_generated_field'])
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
  
  # changes the value of the custom field for issues if necessary
  def update_custom_field(completed)
    if completed == '1'
      to_value = ReleaseNotesHelper::CONFIG['field_value_done']
    else
      to_value = ReleaseNotesHelper::CONFIG['field_value_to_be_done']
    end

    release_notes_required_field_id = CustomField.find_by_name(ReleaseNotesHelper::CONFIG['custom_field']).id
    custom_value = @release_note.issue.custom_values.find_by_custom_field_id(release_notes_required_field_id)

    if !custom_value
      flash[:error] = l(:failed_find_custom_value)
      return
    end
    
    if custom_value.value != to_value
      old_value = custom_value.value
      custom_value.value = to_value
      if custom_value.save
        journal = @release_note.issue.init_journal(User.current)
        journal.details << JournalDetail.new(:property => 'cf',
                                             :prop_key => release_notes_required_field_id,
                                             :old_value => old_value,
                                             :value => to_value)
        if journal.save == false
          flash[:error] = format_release_note_errors(journal, l(:label_history))
        end  
      else
        flash[:error] = format_release_note_errors(custom_value, l(:label_custom_field))
      end
    end
  end
  
  def format_release_note_errors(model, localised_name)
    error_str = ""
    count = model.errors.count
    model.errors.each do |attr, msg|
      error_str << "<br>#{attr}: #{msg}, "
    end
    return_str = l('activerecord.errors.template.header.other',
                        :model => localised_name,
                        :count => count) + ': ' + error_str
    return return_str.chop!.chop!.html_safe
  end
  
end
