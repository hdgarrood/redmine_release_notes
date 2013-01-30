
module RedmineReleaseNotes
  module Patches
    def self.perform(*classes)
      classes.each do |klass|
        patch = "RedmineReleaseNotes::#{klass.name}Patch".constantize
        patch.patch(klass)
      end
    end
  end
end
