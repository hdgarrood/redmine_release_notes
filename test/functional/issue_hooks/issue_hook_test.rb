require File.dirname(__FILE__) + '/../test_helper'

class IssueHookTest < ActionController::TestCase
  def setup
    @controller = IssuesController.new

    # create a release note
    @release_note = FactoryGirl.build(:release_note,
                                      :text => "product can now do backflips")
    @issue = @release_note.issue
    @project = @issue.project

    # create a user
    @user = FactoryGirl.create(:user)

    # give him the permission to view issues in @project
    role = FactoryGirl.create(:role, :permissions => %w(view_issues))
    member = Member.new(:role_ids => [role.id], :user_id => @user.id)
    @project.members << member

    # log him in
    @request.session[:user_id] = @user.id
  end

  def assert_release_notes_displayed
    assert_response :success
    assert_select 'div#release-notes p',
      :text => /product can now do backflips/
  end

  def assert_release_notes_not_displayed
    assert_response :success
    assert_select 'div#release_notes p', false
  end

  test 'release notes displayed if module enabled' do
    @project.enabled_module_names = %w(release_notes)
    @project.save!

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
