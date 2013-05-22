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

module ReleaseNotesHelper
  def release_notes_progress_bar(version)
    completion = version.release_notes_percent_completion
    progress_bar([completion, completion],
                 :width => '40em',
                 :legend => '%0.0f%' % completion)
  end

  def release_notes_overview_link(text, version, project, release_notes_value = nil)
    opts = {
      :f => [:fixed_version_id, :status_id],
      :op => {
        :fixed_version_id => '=',
        :status_id => '*',
      },
      :v => {
        :fixed_version_id => [version.id]
      },
      :set_filter => 1
    }

    if release_notes_value
      opts = add_release_notes_custom_field_filters(opts, release_notes_value)
    end
    opts = add_non_eligible_tracker_filters(opts) 

    link_to text, project_issues_path(project, opts)
  end

  # TODO: behave better when improperly configured
  def add_release_notes_custom_field_filters(opts, release_notes_value)
    orig_opts = opts.dup

    settings = Setting.plugin_redmine_release_notes
    custom_field_id = settings[:issue_custom_field_id].to_i
    custom_field = CustomField.find(custom_field_id)

    field = "cf_#{custom_field_id}"
    opts[:f] << field

    case release_notes_value
    when Hash
      values = release_notes_value[:values].
        map { |v| settings["field_value_#{v}"] }.
        select { |v| custom_field.possible_values.include?(v) }

      opts[:op][field] = release_notes_value[:operator]
      opts[:v][field] = values
    when :none
      # if it's the symbol :none, add a filter to only show issues with no
      # release notes custom field value
      opts[:op][field] = '!*'
    else
      raise <<END
Unrecognised value for +release_notes_value+: <#{release_notes_value}>.
This is a bug. Please report it: https://github.com/hdgarrood/redmine_release_notes
END
    end

    opts
  rescue ActiveRecord::RecordNotFound
    orig_opts
  end

  def add_non_eligible_tracker_filters(opts)
    orig_opts = opts.dup

    settings = Setting.plugin_redmine_release_notes
    custom_field_id = settings[:issue_custom_field_id].to_i
    custom_field = CustomField.find(custom_field_id)

    field = "tracker_id"
    opts[:f] << field
    opts[:op][field] = "!"  

    tracker_query =  " SELECT tracker_id FROM custom_fields_trackers" 
    tracker_query << " WHERE custom_field_id= ?"

    non_eligible_trackers = Tracker.where("id NOT IN (#{tracker_query})",custom_field_id)
    
    opts[:v][field] = non_eligible_trackers.collect(&:id) 

    opts 
  rescue ActiveRecord::RecordNotFound
    orig_opts
  end 

  def release_notes_overview_link_if(condition, text, version, project, opts = {})
    if condition
      release_notes_overview_link(text, version, project, opts)
    else
      text
    end
  end
  
  def render_other_formats(formats)
    str = "<p>"
    str << l(:label_export_to)
    str << " "
    str << formats.map { |format|
      link_to(format.name, generate_release_notes_path(
        :release_notes_format => format.name))
    }.join(' | ')
    str << "</p>"
    str.html_safe
  end
end
