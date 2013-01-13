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
  end

  test 'release notes are displayed on issues#show' do
    get :show, :id => '1'

    assert_response :success
    assert_select 'div.flash.error', false
    assert_select 'p#release_notes',
      :text => /Recipes may now be printed/
  end

  test 'error is shown on issues#show when issue custom field is not set up' do
    with_settings('plugin_redmine_release_notes' =>
                  Setting['plugin_redmine_release_notes'].update(
                    'issue_required_field_id' => 'garbage')) do

      get :show, :id => '1'

      assert_response :success
      assert_select 'div.flash.error',
        :text => I18n.t(:failed_find_issue_custom_field)
    end
  end
end
