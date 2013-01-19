require File.dirname(__FILE__) + '/../test_helper'

class IssueHookTest < ActionController::TestCase
  def setup
    @controller = IssuesController.new

    # this is rather horrible; there should be a better way
    Setting.clear_cache

    @user = FactoryGirl.create(:user)
    User.current = @user

    # set up release notes
    @cf         = FactoryGirl.create(:release_notes_custom_field)
    @settings   = FactoryGirl.create(:release_notes_settings,
                                     :issue_required_field_id => @cf.id)
    @tracker    = FactoryGirl.create(:tracker)
    @project    = FactoryGirl.create(:project, :trackers => [@project])
    @module     = FactoryGirl.create(:enabled_module,
                                     :name => 'release_notes',
                                     :project => @project)
    @issue      = FactoryGirl.create(:issue,
                                     :project => @project,
                                     :tracker => @tracker)
    @issue.release_note = FactoryGirl.create(:release_note,
                                      :text => "product can now do backflips")
  end

  def assert_release_notes_displayed
    assert_response :success
    assert_select 'div.flash.error', false
    assert_select 'div#release_notes>p',
      :text => /product can now do backflips/
  end

  def assert_release_notes_not_displayed
    assert_response :success
    assert_select 'div.flash.error', false
    assert_select 'div#release_notes>p', false
  end

  test 'release notes displayed when custom field is for all projects' do
    @cf.is_for_all = true
    @cf.save!

    get :show, :id => @issue.id

    assert_release_notes_displayed
  end

  test 'release notes displayed when custom field is not for all projects' do
    @cf.is_for_all = false
    @cf.save!
    @project.issue_custom_fields << @cf
    @project.save!

    get :show, :id => @issue.id

    assert_release_notes_displayed
  end

  test 'release notes not displayed if module not enabled for the project' do
    @project.enabled_modules.delete(@module)

    get :show, :id => '1'

    assert_release_notes_not_displayed
  end

  test 'release notes not displayed if project does not have release notes' +
    ' custom field enabled' do
    @project.issue_custom_fields.delete(@cf)

    get :show, :id => '1'

    assert_release_notes_not_displayed
  end

  test "release notes not displayed if issue's tracker does not have the" +
    " release notes custom field" do
    tracker = @project.trackers.first
    tracker.issue_custom_fields.delete(@cf)

    assert_release_notes_not_displayed
  end

  test 'error is shown on issues#show when issue custom field is not set up' do
    @settings.value = @settings.value.
      update('issue_required_field_id' => 'garbage')
    @settings.save!

    get :show, :id => '1'

    assert_response :success
    assert_select 'div.flash.error',
      :text => I18n.t(:failed_find_issue_custom_field)
  end
end
