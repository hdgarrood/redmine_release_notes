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

  def release_notes_overview_link(text, version, project, opts = {})
    opts = {
      :status_id => '*',
      :fixed_version_id => version.id,
      :set_filter => 1
    }.merge(opts)

    opts = add_release_notes_custom_field_filters(opts)
    link_to text, project_issues_path(project, opts)
  end

  # TODO: behave better when improperly configured
  def add_release_notes_custom_field_filters(opts)
    if (release_notes = opts.delete(:release_notes))
      orig_opts = opts.dup

      settings = Setting.plugin_redmine_release_notes
      custom_field_id = settings[:issue_custom_field_id].to_i
      custom_field = CustomField.find(custom_field_id)

      field = "cf_#{custom_field_id}"
      values = release_notes.
        map { |v| settings["field_value_#{v}"] }.
        select { |v| custom_field.possible_values.include?(v) }.
        join('|')

      opts[field] = values
    end
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
