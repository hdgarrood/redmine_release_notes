require 'redmine'
require 'redmine_release_notes/hooks'

# Patches to the Redmine core.
require 'dispatcher'
Dispatcher.to_prepare :redmine_release_notes do
  require_dependency 'issue'
  
  unless Issue.included_modules.include?(RedmineReleaseNotes::IssuePatch)
      Issue.send(:include, RedmineReleaseNotes::IssuePatch)
  end
end

Redmine::Plugin.register :redmine_release_notes do
  name 'Redmine Release Notes plugin'
  author 'Harry'
  description 'This is a plugin for Redmine'
  version '0.0.5'
  
  project_module :release_notes do
    permission :release_notes, { :release_notes => [:index, :new, :generate, :mark_version_as_generated] }, :public => true
  end
  
  menu :project_menu, :release_notes, { :controller => 'release_notes', :action => 'index' }, :caption => 'Release notes', :param => :project_id
  
end
