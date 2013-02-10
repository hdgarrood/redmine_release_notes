require File.dirname(__FILE__) + '/../test_helper.rb'

class IssuePatchTest < ActiveSupport::TestCase
  test "issues return correct value for release_notes_done?" do 
    issue = FactoryGirl.build(:issue)
    issue.build_release_note
    issue.release_note.status = 'done'

    assert issue.release_notes_done?,
      "issue's release notes should be done when release note status == 'done'"

    issue.release_note.status = 'todo'
    assert !issue.release_notes_done?,
      "issue's release notes should not be done when release notes status != 'done'"
  end
end
