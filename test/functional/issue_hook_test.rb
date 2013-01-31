require File.dirname(__FILE__) + '/../test_helper'

class IssueHookTest < ActionController::TestCase
  def setup
    @controller = IssuesController.new

    # this is rather horrible; there should be a better way
    Setting.clear_cache

    # set up release notes
    @release_note = FactoryGirl.build(:release_note)
    @issue = @release_note.issue
    @project = @issue.project

    # allow anonymous user to view issues in this project
    @user = User.anonymous
    @role = @user.roles_for_project(@release_note.issue.project).first
    @role.permissions = [:view_issues]
    @role.save!
  end

  def assert_release_notes_displayed
    assert_response :success
    assert_select 'div#release-notes p',
      :text => /product can now do backflips/
  end

  def assert_release_notes_not_displayed
    assert_response :success
    assert_select 'div#release_notes>p', false
  end

  test 'release notes displayed' do
    get :show, :id => @issue.id
    assert_release_notes_displayed
  end

  test 'release notes not displayed if module not enabled for the project' do
    @project.enabled_modules.where('name = ?', 'release_notes').destroy_all
    @project.save!

    get :show, :id => @issue.id
    assert_release_notes_not_displayed
  end
end
