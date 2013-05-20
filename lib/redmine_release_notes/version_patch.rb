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

module RedmineReleaseNotes
  module VersionPatch
    def self.perform
      Version.class_eval do
        # number, 0 <= n <= 100, the proportion of this version's issues'
        # release notes which are done
        def release_notes_percent_completion
          required_count  = fixed_issues.release_notes_required.count
          if required_count > 0
            done_count = fixed_issues.release_notes_done.count
            100 * done_count / required_count
          else
            0
          end
        end

	def release_notes_stats 
	  stats = Hash.new 
          stats[:required]     = fixed_issues.release_notes_required.count 
          stats[:done]         = fixed_issues.release_notes_done.count 
          stats[:done_empty]   = fixed_issues.done_but_release_notes_nil.count 
          stats[:todo]         = fixed_issues.release_notes_todo.count 
          stats[:not_required] = fixed_issues.release_notes_not_required.count 
          stats[:none]         = fixed_issues.release_notes_none.count 
          stats[:no_cf]        = fixed_issues.release_notes_no_cf_defined.count 
          stats[:invalid]      = fixed_issues.release_notes_invalid.count 
          stats[:nil]          = fixed_issues.release_notes_custom_value_nil.count 
          stats[:total]        = issues_count 
          stats[:completion]   = release_notes_percent_completion 

	  stats
        end 
      end
    end
  end
end
