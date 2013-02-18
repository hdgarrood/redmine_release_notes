require File.dirname(__FILE__) + '/../test_helper'

class SettingsControllerPatchTest < ActionController::TestCase
  def setup
    @controller = SettingsController.new
    
    # run as an admin
    @user = FactoryGirl.create(:user, :admin => true)
    @request.session[:user_id] = @user.id
  end

  test 'uses special view for release notes settings' do
    get :plugin, :id => 'redmine_release_notes'
    assert_response :success
    assert_template 'plugin_release_notes'
  end

  test 'doesnt break other plugin settings' do
    # partly copied from SettingsControllerTest
    Setting.stubs(:plugin_foo).returns({'setting' => 'value'})
    ActionController::Base.append_view_path(File.join(Rails.root, "test/fixtures/plugins"))
    Redmine::Plugin.register :foo do
      settings :partial => "foo_plugin/foo_plugin_settings"
    end

    get :plugin, :id => 'foo'
    assert_response :success
    assert_template 'plugin'
  end

  test "doesn't choke when a non-existent plugin is requested" do
    get :plugin, :id => 'doesnt_exist'
    assert_response 404
  end
end
