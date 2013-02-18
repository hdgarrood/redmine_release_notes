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

module ReleaseNotesFormatsHelper
  def release_notes_preview_link(url, form, target)
    content_tag 'a', l('release_notes.formats.preview'), {
        :href => "#", 
        :onclick => %|submitPreview("#{escape_javascript url_for(url)}", "#{escape_javascript form}", "#{escape_javascript target}"); $("#release_notes_container").show(); return false;|, 
        :accesskey => accesskey(:preview)
      }
  end
end
