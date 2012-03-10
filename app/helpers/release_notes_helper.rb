# Copyright © 2012  Harry Garrood
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

module ReleaseNotesHelper

  CONFIG = YAML.load_file("#{RAILS_ROOT}/vendor/plugins/redmine_release_notes/config/config.yml")
 
  def generate_release_notes(version_id, format)
    output_str = ""
    null_release_notes = []
    count_release_notes_to_be_done = Issue.release_notes_to_be_done(version_id).count
    version = Version.find(version_id)
    release_notes_required_field_id = CustomField.find_by_name(CONFIG['issue_required_field']).id
    
    output_str << format['start'] + "\n"
  
    version.fixed_issues.each do |issue|
      
      release_notes_required_field = issue.custom_values.find_by_custom_field_id(release_notes_required_field_id)
      if !release_notes_required_field
        next
      end

      release_notes_required = release_notes_required_field.value
      if release_notes_required != CONFIG['field_value_done']
        next
      end
      
      if issue.release_note
        values = {"subject" => issue.subject, "release_notes" => issue.release_note.text}
        output_str << make_substitutions(format['each_issue'], values) + "\n"
      else
        null_release_notes << issue.id
      end
    end

    output_str << format['end']
    
    if (count_release_notes_to_be_done > 0) || (null_release_notes != [])
      flash.now[:warning] = ""
      if count_release_notes_to_be_done > 0
        flash.now[:warning] << l('some_issues_not_finished.' + (count_release_notes_to_be_done == 1 ? 'one' : 'other'),
                                    :count => count_release_notes_to_be_done)
                                    
        link_str = link_to "show",
                :action => "index",
                :controller => "issues",
                :project_id => @project.identifier,
                :set_filter => "1",
                :v => {"fixed_version_id"=>[version_id],
                       "cf_#{release_notes_required_field_id}"=>[CONFIG['field_value_to_be_done']]},
                :op => {"fixed_version_id"=>"=",
                        "cf_#{release_notes_required_field_id}"=>"="},
                :f =>["fixed_version_id",
                      "cf_#{release_notes_required_field_id}"]
                      
        flash.now[:warning] << " (#{link_str})<br>"
      end
      if null_release_notes != []
        flash.now[:warning] << l(:some_issues_no_release_notes_html,
                                :list => comma_format_list(null_release_notes),
                                :field => CONFIG['issue_required_field'],
                                :value => CONFIG['field_value_done'])
      end
    end
    
    return output_str
  end
  
  def generate_release_notes_header(version_id, format)
    version = Version.find(version_id)
    values = { "name" => version.name, "date" => format_date(version.effective_date) }
    str = make_substitutions(format['header'], values) 
    return str
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def render_other_formats(formats)
    str = "<p>"
    str << l(:label_export_to)
    str << " "
    formats.keys.each do |format|
      str << link_to(format, {:action => "generate", :controller => "release_notes", :release_notes_format => format})
      str << " | "
    end
    3.times { str.chop! }
    return str
  end

  # Utility code below here. Might be better off somewhere else but meh.
  
  def comma_format_list(list)
    str = ""
      list.each do |item|
      str << "#{item}, "
      end
    2.times do str.chop! end
      str << "."
    return str
  end
  
  def make_substitutions(string, subs)
    return_str = string.gsub(/%\{.*?\}/) do |match|
      subs[match[2..-2]] or match[2..-2]
    end
    return return_str
  end

end

