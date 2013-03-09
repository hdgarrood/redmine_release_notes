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

module ReleaseNotesSettingsHelper
  def release_notes_settings_tabs
    [
      {:name => 'general',
        :partial => 'settings/release_notes_general',
        :label => :label_general},
      {:name => 'formats',
        :partial => 'settings/release_notes_formats',
        :label => 'release_notes.formats.title'}
    ]
  end

  def options_for_release_notes_issue_custom_field(settings)
    custom_fields = IssueCustomField.where(:field_format => 'list')
    selected = settings['issue_custom_field_id'].to_i
    options_from_collection_for_select(custom_fields, 'id', 'name', selected)
  end

  def options_for_release_notes_issue_custom_field_value(settings, selected)
    custom_field = CustomField.find(settings['issue_custom_field_id'].to_i)
    values = custom_field.possible_values
    options_for_select(values, selected)
  rescue ActiveRecord::RecordNotFound
    []
  end
end
