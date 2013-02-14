require File.dirname(__FILE__) + '/../test_helper'

class ReleaseNotesControllerPatchTest < ActionController::TestCase
  def setup
    @controller = ReleaseNotesController.new

    # run as an admin
    @user = FactoryGirl.create(:user, :admin => true)
    @request.session[:user_id] = @user.id
  end

  test "don't try to generate without any formats" do
    assert_equal ReleaseNotesFormat.count, 0,
      "this test will only work if there are no formats in the db"

    version = FactoryGirl.create(:version_with_release_notes)

    get :generate, :id => version.id
    assert_template 'no_formats'
  end

  test "should use default format when not specified" do
    version = FactoryGirl.create(:version_with_release_notes)
    format = FactoryGirl.create(:release_notes_format)

    Setting.stubs(:plugin_redmine_release_notes).
      returns(:default_generation_format_id => format.id)

    get :generate, :id => version.id
    assert_template 'generate'
    assert_equal assigns(:format), format
  end

  test "should use default format when specified format not found" do
    version = FactoryGirl.create(:version_with_release_notes)
    format = FactoryGirl.create(:release_notes_format)

    Setting.stubs(:plugin_redmine_release_notes).
      returns(:default_generation_format_id => format.id)

    get :generate, :id => version.id, :release_notes_format => 'garbage'
    assert_template 'generate'
    assert_equal assigns(:format), format
  end

  test "should use specified format" do
    version = FactoryGirl.create(:version_with_release_notes)
    format = FactoryGirl.create(:release_notes_format)

    # ensure the format is not retrieved from settings
    Setting.stubs(:plugin_redmine_release_notes).
      returns(:default_generation_format_id => 0)

    get :generate, :id => version.id, :release_notes_format => format.name
    assert_template 'generate'
    assert_equal assigns(:format), format
  end
end
