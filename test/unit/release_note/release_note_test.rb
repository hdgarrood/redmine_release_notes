require File.dirname(__FILE__) + '/../../test_helper'

class ReleaseNoteTest < ActiveSupport::TestCase
  test 'release notes belong to issues' do
    rn = FactoryGirl.build(:release_note)
    assert rn.respond_to?(:issue),
      "release notes should respond to :issue"
  end

  test 'release notes are invalid unless they have both text and an issue' do
    rn = FactoryGirl.build(:release_note, :text => nil, :issue => nil)
    assert !rn.valid?,
      "release notes should not be valid without text or an associated issue"

    rn.issue = FactoryGirl.build(:issue)
    rn.text = "now fixed!"
    assert rn.valid?,
      "release notes should be valid when they have text and an issue"
  end

  test 'release notes may have text up to 2000 chars but not longer' do
    rn = FactoryGirl.build(:release_note, :text => "a" * 2000)
    assert rn.valid?,
      "release notes should be valid when their text is 2000 chars long"

    rn.text += "b"
    assert !rn.valid?,
      "release notes should not be valid when their text is 2001 chars long"
  end

  test 'release notes are completed when their issues are completed' do
    mock_issue = Object.new
    def mock_issue.release_notes_completed?; true; end

    rn = ReleaseNote.new
    def rn.issue; @mock_issue; end
    rn.instance_variable_set(:@mock_issue, mock_issue)

    assert rn.completed?,
      "release notes should be completed if their issues are completed"

    def mock_issue.release_notes_completed?; false; end

    assert !rn.completed?,
      "release notes should not be completed unless their issues are completed"
  end
end
