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
  
  before_filter :find_version, :only => [:generate, :mark_version_as_generated]
  
  helper :custom_fields
  helper :projects
  
  def index
    # Pretty much copied from VersionsController#index
    @project = Project.find(params[:project_id])
    
    @with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')
    project_ids = @with_subprojects ? @project.self_and_descendants.collect(&:id) : [@project.id]
    
    @versions = @project.shared_versions || []
    @versions += @project.rolled_up_versions.visible if @with_subprojects
    @versions = @versions.uniq.sort
      
    # Find the custom field id for release notes generated
    release_notes_generated_cf_id = CustomField.find_by_name(ReleaseNotesHelper::CONFIG['version_generated_field']).id
    
    # want to reject versions with release notes completed, as opposed to closed versions
    if !params[:completed]
      @versions.reject! do |version|
        cv = version.custom_values.first(:conditions => { :custom_field_id => release_notes_generated_cf_id })
        if cv
          # rejects if version is generated
          cv.value == "1"
        else
          # doesn't reject
          false
        end
      end
    end
    
    @issues_by_version = {}
    @versions.each do |version|
      issues = version.fixed_issues.visible.find(:all,
                                                 :include => [:project, :status, :tracker, :priority],
                                                 :conditions => {:tracker_id => @selected_tracker_ids, :project_id => project_ids},
                                                 :order => "#{Project.table_name}.lft, #{Tracker.table_name}.position, #{Issue.table_name}.id")
      @issues_by_version[version] = issues
    end
    
    @versions.reject! {|version| !project_ids.include?(version.project_id) && @issues_by_version[version].blank?}
    
    @release_notes_required_cf_id = CustomField.find_by_name(ReleaseNotesHelper::CONFIG['issue_required_field']).id
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def show
    release_note = ReleaseNote.find(params[:id])
    redirect_to :controller => "issues", :action => "show", :id => release_note.issue_id
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
    release_notes_cf_id = CustomField.find_by_name(ReleaseNotesHelper::CONFIG['issue_required_field']).id
    release_notes_completed_value = @issue.custom_values.find_by_custom_field_id(release_notes_cf_id).value
    @release_notes_completed = (release_notes_completed_value == ReleaseNotesHelper::CONFIG['field_value_done'])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def create
    @release_note = ReleaseNote.create(:text => params[:release_note][:text])
    @issue = Issue.find(params[:release_note][:issue_id])
    @issue.release_note = @release_note

    if @issue.save
      flash[:notice] = l(:notice_successful_create)
      update_custom_field(params[:mark_complete])
      redirect_to :controller => 'issues', :action => 'show', :id => @issue.id
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
      error_str = format_release_note_errors(@release_note, l(:release_note).downcase)
      flash[:error] = error_str
      redirect_to :action => "edit", :id => params[:id]
      return
    end
    
    update_custom_field(params[:mark_complete])
    
    redirect_to :controller => 'issues', :action => 'show', :id => @release_note.issue.id
    return
    
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def destroy
    if request.delete?
      release_note = ReleaseNote.find(params[:id])
      issue_id = release_note.issue_id
      release_note.destroy
      redirect_to :action => 'show', :controller => 'issues', :id => issue_id
      flash[:notice] = l(:notice_successful_delete)
    else
      render_403
    end
  end
  
  def generate
    @project = @version.project
    @formats = YAML.load_file("#{Rails.root}/plugins/redmine_release_notes/config/formats.yml")
    @format = params[:release_notes_format]
    if @formats[@format].nil? or @formats[@format].empty?
      @format = ReleaseNotesHelper::CONFIG['default_generation_format']
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
  
  # changes the value of the custom field for issues if necessary
  def update_custom_field(completed)
    if completed == '1'
      to_value = ReleaseNotesHelper::CONFIG['field_value_done']
    else
      to_value = ReleaseNotesHelper::CONFIG['field_value_to_be_done']
    end

    release_notes_required_field_id = CustomField.find_by_name(ReleaseNotesHelper::CONFIG['issue_required_field']).id
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
