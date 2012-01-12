module ReleaseNotesHelper
  
  def generate_release_notes(version_id)
    output_str = ""
	null_release_notes = []
	no_raised_by_data = []
	count_release_notes_to_be_done = Issue.release_notes_to_be_done(version_id).count
	
    version = Version.find(version_id)
	
	path_field_id = CustomField.find_by_name("Path").id
	release_notes_required_field_id = CustomField.find_by_name("Release notes required").id
	raised_by_internal_field_id = CustomField.find_by_name("Raised by internal").id
	raised_by_external_field_id = CustomField.find_by_name("Raised by external").id
	
	version.fixed_issues.each do |issue|
	  release_notes_required = issue.custom_values.find_by_custom_field_id(release_notes_required_field_id).value
	  if release_notes_required != 'Yes - done'
		next
	  end
	  
	  output_str << "\n"
      if issue.assigned_to_id
        assignee = User.find(issue.assigned_to_id) 
        output_str << "#{issue.subject.upcase} {developed by #{assignee.login}}\n" 
      else 
        output_str << "#{issue.subject.upcase}\n"
      end 
	  
	  # Underline subject
      issue.subject.length.times do output_str << "=" end
	  output_str << "\n"
	  
	  # Write the path
	  path = issue.custom_values.find_by_custom_field_id(path_field_id).value
	  if path != ""
	    output_str << "#{path}\n"
	  end
	  
	  # Write the release note text
      if issue.release_note 
        output_str << "#{issue.release_note.text}\n"
	  else
	    null_release_notes << issue.id.to_s
		output_str << "<< No release notes found >>\n"
      end
	  
	  # Get the raised by value
	  raised_internal_value = issue.custom_values.find_by_custom_field_id(raised_by_internal_field_id).value
	  raised_external_value = issue.custom_values.find_by_custom_field_id(raised_by_external_field_id).value
	  
	  # User ID 2 is anonymous
	  if raised_internal_value
		  if !raised_internal_value.empty? && raised_internal_value != "2"
			# raised_external_value is a user id
			raiser = User.find(raised_internal_value)
		  end
	  end
	  
	  # Possibility 1: There is a value for Raised by internal
	  if raiser
	    output_str << "[Internal Suggestion] {#{raiser.login}}\n"
		
	  # Possibility 2: Raised by external == "See description"
	  elsif raised_external_value == "See description"
	    # Get the raised by from the description, if it exists
		raised_by = issue.description.slice(/\ARaised by .*/)
		if raised_by
		  raised_by = raised_by.slice(10,200).chomp!
		  output_str << "[#{raised_by}]\n"
		else
		  no_raised_by_data << issue.id.to_s
		end
		
	  # Possibility 3: Raised by external is some other value (other than no record)
	  elsif raised_external_value != 'No record' && raised_external_value != ""
	    output_str << "[#{raised_external_value}]\n"
		
	  # Possibility 4: There is no data
	  else
	    output_str << "[Unknown]\n"
		no_raised_by_data << issue.id.to_s
	  end
	  
	  output_str << "{#{issue.id}}\n"
    end
	if count_release_notes_to_be_done + null_release_notes.length + no_raised_by_data.length > 0
	  flash.now[:warning] = "Warnings: "
	  if count_release_notes_to_be_done > 0
	    release_notes_to_be_done_link = link_to "go to issues list", :action => "index", :controller => "issues", :project_id => @project.identifier, :set_filter => "1", :v => {"fixed_version_id"=>[version.id], "cf_#{release_notes_required_field_id}"=>["Yes - to be done"]}, :op => {"fixed_version_id"=>"=", "cf_#{release_notes_required_field_id}"=>"="}, :f =>["fixed_version_id", "cf_#{release_notes_required_field_id}"]
	    flash.now[:warning] << "There are #{count_release_notes_to_be_done} issues which still need release notes! (#{release_notes_to_be_done_link})<br />"
	  end
	  if null_release_notes.length > 0
		str = comma_format_list(null_release_notes)
	    flash.now[:warning] << "There are #{null_release_notes.length} issues with Release notes required = \"Yes - done\" but no release notes. (<a href=\"#\" onclick=\"alert(&quot;Issues with no release notes: #{str}&quot;)\">show</a>)<br />"
	  end
	  if no_raised_by_data.length > 0
		str = comma_format_list(no_raised_by_data)
	    flash.now[:warning] << "There are #{no_raised_by_data.length} issues in this output with no raised by data. (<a href=\"#\" onclick=\"alert(&quot;Issues with no raised by data: #{str}&quot;)\">show</a>)"
	  end
	end
	output_str
  end
  
  def generate_release_notes_header(version_id)
    version = Version.find(version_id)
    str = ""
	
	50.times do str << "-" end
	str << "\n"
	str << "Version: #{version.name}"
	if version.effective_date
	  str << "     Date: #{format_date(version.effective_date)}"
	end
	str << "\n"
	50.times do str << "-" end
	str
  end
  
  def comma_format_list(list=nil)
	str = ""
    list.each do |item|
	  str << "#{item}, "
    end
	2.times do str.chop! end
    str << "."
	return str
  end
end
