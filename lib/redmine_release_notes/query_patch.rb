module RedmineReleaseNotes
  module QueryPatch
    extend Patch

    def self.do_patch(klass)
      klass.add_available_column(ReleaseNotesQueryColumn)
    end
  end
end
