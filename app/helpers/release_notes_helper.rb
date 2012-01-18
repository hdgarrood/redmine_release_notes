module ReleaseNotesHelper
  
  def generate_release_notes(version_id)
    output_str = ""
	  null_release_notes = []
	  no_raised_by_data = []
	  count_release_notes_to_be_done = Issue.release_notes_to_be_done(version_id).count
	
    version = Version.find(version_id)
	
	  release_notes_required_field_id = CustomField.find_by_name("Release notes required").id
	
	  version.fixed_issues.each do |issue|
	    release_notes_required = issue.custom_values.find_by_custom_field_id(release_notes_required_field_id).value
	    if release_notes_required != 'Yes - done'
		    next
	    end
	  end
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
