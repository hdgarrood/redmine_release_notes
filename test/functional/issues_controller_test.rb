require File.dirname(__FILE__) + '/../test_helper'

class IssuesControllerTest < ActionController::TestCase
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
    :workflows

  test 'error is shown on issues#show when issue custom field is not set up' do
    get :show, :id => '1'
    assert_response :success
    assert_select 'div.flash.error',
      :text => I18n.t(:failed_find_issue_custom_field)
  end
end
