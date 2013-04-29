require File.dirname(__FILE__) + '/../test_helper.rb'

class IssuePatchTest < ActiveSupport::TestCase
  test "issues return correct value for release_notes_done?" do
    # TODO
  end

  test 'should only be eligible for release notes when project and tracker are setup' do
    # create a tracker which is enabled for release notes
    enabled_tracker = FactoryGirl.create(:tracker)
    Setting.stubs(:plugin_redmine_release_notes).
      returns({:enabled_tracker_ids => [enabled_tracker.id]})
    # create a project which is enabled for release notes
    enabled_project = FactoryGirl.create(:project_with_release_notes,
                                 :trackers => [enabled_tracker])

    issue = FactoryGirl.build(:issue)
    issue.tracker = enabled_tracker
    issue.project = enabled_project
    assert issue.eligible_for_release_notes?,
      "issue should be eligible for release notes"

    tracker = FactoryGirl.create(:tracker)
    issue.tracker = tracker
    assert !issue.eligible_for_release_notes?,
      "issue should not be eligible for release notes because of the tracker"

    issue.tracker = enabled_tracker
    issue.project = FactoryGirl.create(:project)
    assert !issue.eligible_for_release_notes?,
      "issue should not be eligible for release notes because of the project"
  end
end
