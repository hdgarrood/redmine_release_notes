require File.dirname(__FILE__) + '/../../test_helper'

class ReleaseNoteTest < ActiveSupport::TestCase
  fixtures 'issues'
  fixtures 'release_notes'

  test 'release notes belong to issues' do
    rn = ReleaseNote.new
    assert rn.respond_to?(:issue)
  end

  test 'release notes are invalid unless they have both text and an issue' do
    rn = ReleaseNote.new
    assert !rn.valid?

    rn.issue = issues(:issues_001)
    rn.text = "now fixed!"
    assert rn.valid?
  end

  test 'release notes may have text up to 2000 chars but not longer' do
    rn = release_notes(:release_notes_001)
    rn.text = "a" * 2000
    assert rn.valid?

    rn.text += "b"
    assert !rn.valid?
  end
end
