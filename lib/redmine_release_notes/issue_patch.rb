# Patches Redmine's Issues dynamically.
# Adds a relationship - an issue has one release note
# Adds methods for counting required and completed release notes for a version

require 'yaml'

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

module RedmineReleaseNotes

  # Yes, I know this also happens in ReleaseNotesHelper. I am very sorry for this awful practice.
  RELEASE_NOTES_CONFIG = YAML.load_file("#{RAILS_ROOT}/vendor/plugins/redmine_release_notes/config/config.yml")

  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        has_one :release_note, :dependent => :destroy
        validates_associated :release_note
        
        named_scope :release_notes_required, lambda { |version_id|
          {
            :joins => :custom_values,
            :conditions => ['custom_values.value <> ? and custom_values.custom_field_id = ? and fixed_version_id = ?',
              RELEASE_NOTES_CONFIG['field_value_not_required'],
              CustomField.find_by_name(RELEASE_NOTES_CONFIG['issue_required_field']).id.to_s,
              version_id.to_s]
          }
        }
          
        named_scope :release_notes_completed, lambda { |version_id|
          {
            :joins => :custom_values,
            :conditions => ['custom_values.value = ? and custom_values.custom_field_id = ? and fixed_version_id = ?',
              RELEASE_NOTES_CONFIG['field_value_done'],
              CustomField.find_by_name(RELEASE_NOTES_CONFIG['issue_required_field']).id.to_s,
              version_id.to_s]
          }
        }
          
        named_scope :release_notes_to_be_done, lambda { |version_id|
          {
            :joins => :custom_values,
            :conditions => ['custom_values.value = ? and custom_values.custom_field_id = ? and fixed_version_id = ?',
              RELEASE_NOTES_CONFIG['field_value_to_be_done'],
              CustomField.find_by_name(RELEASE_NOTES_CONFIG['issue_required_field']).id.to_s,
              version_id.to_s]
          }
        }
        
      end #base.class_eval
    end #self.included(base)
    
      module ClassMethods
      end
    
      module InstanceMethods
      end
      
  end #IssuePatch
end #RedmineReleaseNotes
