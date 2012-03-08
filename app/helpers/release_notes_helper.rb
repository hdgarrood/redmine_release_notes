module ReleaseNotesHelper
  
  def generate_release_notes(version_id)
    output_str = ""
    null_release_notes = []
    count_release_notes_to_be_done = Issue.release_notes_to_be_done(version_id).count
  
    version = Version.find(version_id)
  
    release_notes_required_field_id = CustomField.find_by_name(l(:release_notes_required)).id
  
    version.fixed_issues.each do |issue|

      release_notes_required_field = issue.custom_values.find_by_custom_field_id(release_notes_required_field_id)
      if !release_notes_required_field
        next
      end

      release_notes_required = release_notes_required_field.value
      if release_notes_required != l(:release_note_to_be_done)
        next
      end
      
      if issue.release_note
        output_str << issue.to_s + "\n" + issue.release_note.text + "\n\n"
      else
        null_release_notes << issue.id
      end
    end
    
    if count_release_notes_to_be_done > 0 or null_release_notes != []
      flash.now[:warning] = ""
      if count_release_notes_to_be_done > 0
        flash.now[:warning] << "There #{count_release_notes_to_be_done == 1 ? "is 1 issue which still needs" : "are " + count_release_notes_to_be_done.to_s + "issues which still need"} release notes (#{link_to "show", :action => "index", :controller => "issues", :project_id => @project.identifier, :set_filter => "1", :v => {"fixed_version_id"=>[version_id], "cf_#{release_notes_required_field_id}"=>["Yes - to be done"]}, :op => {"fixed_version_id"=>"=", "cf_#{release_notes_required_field_id}"=>"="}, :f =>["fixed_version_id", "cf_#{release_notes_required_field_id}"]})<br />"
      end
      if null_release_notes != []
        logger.info "null release notes = #{null_release_notes.to_s}"
        flash.now[:warning] << l(:some_issues_no_release_notes_html, :list => comma_format_list(null_release_notes))
      end
    end
    
    return output_str
  end
  
  def generate_release_notes_header(version_id)
    version = Version.find(version_id)
    str = ""
    str << "Release notes for version #{version.name}\n"
    str
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def comma_format_list(list)
    str = ""
      list.each do |item|
      str << "#{item}, "
      end
    2.times do str.chop! end
      str << "."
    return str
  end
end

