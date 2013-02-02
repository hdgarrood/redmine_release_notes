
module RedmineReleaseNotes
  module Patch
    def perform
      logger.warn 'tried to perform a patch twice' if @already_patched
      unless @already_patched
        _perform
        @already_patched = true
      end
    end
  end
end
