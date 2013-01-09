require File.dirname(__FILE__) + '/../../test_helper.rb'

class IssuePatchTest < ActiveSupport::TestCase
  fixtures :issues,
    :projects,
    :users,
    :trackers,
    :enumerations, #for priority
    :issue_statuses,
    :projects_trackers,
    :release_notes

  test 'an issue has one release note' do
    i = Issue.new
    assert i.respond_to?(:release_note),
      "i should respond to :release_note"
  end

  test 'issues validate their associated release note' do
    # create a yet-to-be-saved valid issue
    i = get_an_unsaved_valid_issue

    # add an invalid release note
    i.release_note = ReleaseNote.new
    assert !i.valid?,
      "i should be invalid because its release note is invalid"

    # make it a valid one, so that it saves
    i.release_note.text = "ok, i fixed it"
    assert i.valid?,
      "i should be valid because its release note is valid. Errors:\n" +
      i.release_note.errors.full_messages.join(", ")
  end

  def get_an_unsaved_valid_issue
    i = Issue.new
    i.subject = 'everything is broken'
    i.project = projects(:projects_001)
    i.author = users(:users_001)
    i.tracker = trackers(:trackers_001)
    i
  end
end
