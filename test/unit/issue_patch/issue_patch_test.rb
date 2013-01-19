require File.dirname(__FILE__) + '/../../test_helper.rb'

class IssuePatchTest < ActiveSupport::TestCase
  test 'an issue has one release note' do
    i = FactoryGirl.build(:issue)
    assert i.respond_to?(:release_note),
      "i should respond to :release_note"
  end

  test 'issues validate their associated release note' do
    i = FactoryGirl.build(:issue)

    i.release_note = FactoryGirl.build(:release_note,
                                       :text => nil, :issue => nil)
    assert !i.valid?,
      "i should be invalid because its release note is invalid"

    i.release_note.text = "ok, i fixed it"
    assert i.valid?,
      "i should be valid because its release note is valid. Errors:\n" +
      i.errors.full_messages.join(", ")
  end
end
