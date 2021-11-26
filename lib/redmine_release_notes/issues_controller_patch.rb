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
  module IssuesControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        after_action :add_releasenotes_fields, :only => [:index, :show]
      end
    end
    def self.perform
      IssuesController.class_eval do
        helper 'release_notes'
      end
    end
    module ClassMethods
    end
    module InstanceMethods
      def add_releasenotes_fields
        if include_in_api_response?('release_notes')
          case params[:format]
          when 'xml'
            body = Nokogiri::XML(response.body)
            body.xpath('//issue').each { |xmlissue|
              issue = Issue.find(xmlissue.at('.//id').text)
              next unless issue.release_notes_done?
              xmlissue << body.create_element('release_note', issue.release_note.text)
            }
            response.body = body.to_xml
          when 'json'
            jsonp = (request.params[:callback] || request.params[:jsonp]).to_s.gsub(/[^a-zA-Z0-9_]/, '')
            body = JSON.parse(jsonp.present? ? response.body.sub("#{jsonp}(", "").chop : response.body)
            (body['issues'] || [body['issue']]).each{|j_issue|
              issue = Issue.find(j_issue['id'])
              next unless issue.release_notes_done?
              j_issue['release_note'] = issue.release_note.text
            }
            response.body = jsonp.present? ? "#{jsonp}(#{body.to_json})" : body.to_json
          end
        end
      end
    end
  end
end

IssuesController.send(:include, RedmineReleaseNotes::IssuesControllerPatch) unless IssuesController.included_modules.include? RedmineReleaseNotes::IssuesControllerPatch
