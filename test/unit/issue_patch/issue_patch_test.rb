require File.dirname(__FILE__) + '/../../test_helper.rb'

class IssuePatchTest < ActiveSupport::TestCase
  fixtures 'issues'

  test 'an issue has one release note' do
    i = Issue.new
    assert i.respond_to?(:release_note),
      "i should respond to :release_note"
  end

  test 'issues validate their associated release note' do
    i = issues(:issues_001).find
    i.release_note = ReleaseNote.new
    assert !i.valid?,
      "i should be invalid because its release note is invalid"

    i.release_note = release_notes(:release_notes_001)
    assert i.valid?,
      "i should be valid because its release note is valid"
  end
end
