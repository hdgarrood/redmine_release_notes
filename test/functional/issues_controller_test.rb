require File.dirname(__FILE__) + '/../test_helper'

class IssuesControllerTest < ActionController::TestCase
  fixtures :custom_fields,
    :custom_values,
    :issue_categories,
    :issue_statuses,
    :issues,
    :member_roles,
    :members,
    :projects,
    :release_notes,
    :roles,
    :users

  def setup
    # run as redmine admin
  end

  test 'error is shown on issues#show when issue custom field is not set up' do
    @request.session[:user_id] = 1
    get :show, :id => '1'
    assert_response :success
    assert_select 'div.flash.error', I18n.l(:failed_find_issue_custom_field)
  end
end
