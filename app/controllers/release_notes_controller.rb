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
	  release_notes_generated_cf_id = CustomField.find_by_name('Release notes generated').id
	
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
	
	  @release_notes_required_cf_id = CustomField.find_by_name("Release notes required").id
	  logger.info @release_notes_required_cf_id.to_s
	
  end
  
  def new
    @issue = Issue.find(params[:issue_id])
	  @project = @issue.project
	
	  @release_note = ReleaseNote.new
	  @issue.release_note = @release_note
    render :action => 'edit'
	  rescue ActiveRecord::RecordNotFound
	    render_404
  end
  
  def edit
    @release_note = ReleaseNote.find(params[:id])
	  @issue = @release_note.issue
	  @project = @issue.project
	  rescue ActiveRecord::RecordNotFound
  	  render_404
  end
  
  def create
    @release_note = ReleaseNote.create(:text => params[:release_note][:text])
    @issue = Issue.find(params[:release_note][:issue_id])
	  @issue.release_note = @release_note
	
    if @issue.save
	    if params[:mark_complete] == '1'
	      update_custom_field
	    end
	  redirect_to :controller => 'issues', :action => 'show', :id => @issue.id
	  else
	    render :action => 'edit', :id => params[:release_note][:id]
	    flash.now[:error] = "Failed to save. Does the issue still exist?"
    end
	  rescue ActiveRecord::RecordNotFound
	    render_404
  end
  
  def update
    release_note = ReleaseNote.find(params[:id])
    release_note.text = params[:release_note][:text]
    if release_note.save
      flash[:notice] = "Successfully saved."
    else
      flash[:error] = "Failed to save."
      redirect_to :action => "edit", :id => params[:id]
    end
    
	  if params[:mark_complete] == '1'
	    update_custom_field
	  end
	  
	  redirect_to :controller => 'issues', :action => 'show', :id => release_note.issue.id
	  
    rescue ActiveRecord::RecordNotFound
  	  render_404
  end
  
  def generate
    @project = @version.project
  end
  
  def mark_version_as_generated
    @project = @version.project
    generated_field_id = CustomField.find_by_name("Release notes generated")
    custom_value = @version.custom_values.find_by_custom_field_id(generated_field_id)
  	custom_value.value = 1
    if custom_value.save
  	  flash.now[:notice] = "Version updated."
	  else
	    flash.now[:error] = "Failed to save version."
	  end
	  rescue ActiveRecord::RecordNotFound
	    flash.now[:error] = "Couldn't find the custom field for versions - release notes generated"
  end
  
 private  
  def find_version
    @version = Version.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  # Set the value of the release notes custom issue field to 'Yes - done' if the user wanted to
  def update_custom_field
	  release_notes_required_field_id = CustomField.find_by_name("Release notes required").id
	  custom_values = @release_note.issue.custom_values.find_by_custom_field_id(release_notes_required_field_id)
    if custom_values.value != 'Yes - done'
	    custom_values.value = 'Yes - done'
      if custom_values.save
    	  journal = @release_note.issue.init_journal(User.current)
	      journal.details << JournalDetail.new(:property => 'cf',
	                                          :prop_key => release_notes_required_field_id,
										                        :old_value => 'Yes - to be done',
                  										      :value => 'Yes - done')
          if journal.save == false
      		  flash[:warning] = "Failed to save Release notes required field update in issue history."
	      	end  
	      else
	        flash[:warning] = "Failed to save value for field: Release notes required."
	      end
	  end
  end
  
end
