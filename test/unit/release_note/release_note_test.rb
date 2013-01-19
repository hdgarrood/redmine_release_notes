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
end
