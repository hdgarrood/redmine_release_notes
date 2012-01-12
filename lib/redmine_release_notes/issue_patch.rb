# Patches Redmine's Issues dynamically.
# Adds a relationship - an issue has one release note
# Adds methods for counting required and completed release notes for a version

module RedmineReleaseNotes
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
          { :joins => :custom_values, :conditions => ['custom_values.value <> ? and custom_values.custom_field_id = ? and fixed_version_id = ?', 'No - not applicable', CustomField.find_by_name("Release notes required").id.to_s, version_id.to_s] }
          }
          
        named_scope :release_notes_completed, lambda { |version_id|
          { :joins => :custom_values, :conditions => ['custom_values.value = ? and custom_values.custom_field_id = ? and fixed_version_id = ?', 'Yes - done', CustomField.find_by_name("Release notes required").id.to_s, version_id.to_s] }
          }
          
        named_scope :release_notes_to_be_done, lambda { |version_id|
          { :joins => :custom_values, :conditions => ['custom_values.value = ? and custom_values.custom_field_id = ? and fixed_version_id = ?', 'Yes - to be done', CustomField.find_by_name("Release notes required").id.to_s, version_id.to_s] }
          }
      end #base.class_eval
    end #self.included(base)
    
      module ClassMethods
      end
    
      module InstanceMethods
      end
      
  end #IssuePatch
end #RedmineReleaseNotes
