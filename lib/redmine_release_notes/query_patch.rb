module RedmineReleaseNotes
  module QueryPatch
    def self.perform
      Query.add_available_column(ReleaseNotesQueryColumn)
    end
  end
end
