require File.dirname(__FILE__) + '/../test_helper'

class IssueHookTest < ActionController::TestCase
  fixtures :custom_fields_projects,
    :custom_fields_trackers,
    :custom_fields,
    :custom_values,
    :enabled_modules,
    :enumerations,
    :issue_categories,
    :issue_statuses,
    :issues,
    :member_roles,
    :members,
    :projects_trackers,
    :projects,
    :release_notes,
    :roles,
    :trackers,
    :users,
    :workflows,
    :settings # for release notes plugin config

  def setup
    @controller = IssuesController.new

    # this is rather horrible; there should be a better way
    Setting.clear_cache
  end

  test 'release notes are displayed on issues#show' do
    get :show, :id => '1'

    assert_response :success
    assert_select 'div.flash.error', false
    assert_select 'div#release_notes>p',
      :text => /Recipes may now be printed/
  end

  test 'release notes not displayed if module not enabled for the project' do
    proj = projects(:projects_001)
    proj.enabled_modules.delete(enabled_modules(:release_notes))

    get :show, :id => '1'
    assert_response :success
    assert_select 'div.flash.error', false
    assert_select 'div#release_notes>p', false
  end

  test 'release notes not displayed if project does not have release notes' +
    'custom field enabled' do
    proj = projects(:projects_001)
    proj.issue_custom_fields.delete(custom_fields(:custom_fields_001))

    get :show, :id => '1'
    assert_response :success
    assert_select 'div.flash.error', false
    assert_select 'div#release_notes>p', false
  end

  test "release notes not displayed if issue's tracker does not have the" +
    "release notes custom field" do
    tracker = trackers(:bug)
    tracker.custom_fields.delete(custom_fields(:custom_fields_001))

    get :show, :id => '1'
    assert_response :success
    assert_select 'div.flash.error', false
    assert_select 'div#release_notes>p', false
  end

  test 'error is shown on issues#show when issue custom field is not set up' do
    # change the issue required field id just for this test
    s = Setting.find_by_name(:plugin_redmine_release_notes)
    s.value = s.value.update('issue_required_field_id' => 'garbage')
    s.save!

    get :show, :id => '1'

    assert_response :success
    assert_select 'div.flash.error',
      :text => I18n.t(:failed_find_issue_custom_field)
  end
end
