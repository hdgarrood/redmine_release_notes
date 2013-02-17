module ReleaseNotesFormatsHelper
  def release_notes_preview_link(url, form, target)
    content_tag 'a', l('release_notes.formats.preview'), {
        :href => "#", 
        :onclick => %|submitPreview("#{escape_javascript url_for(url)}", "#{escape_javascript form}", "#{escape_javascript target}"); $("#release_notes_container").show(); return false;|, 
        :accesskey => accesskey(:preview)
      }
  end
end
