
module RedmineReleaseNotes
  module Patch
    def patch(klass)
      unless @already_patched
        do_patch(klass)
        @already_patched = true
      end
    end
  end
end
