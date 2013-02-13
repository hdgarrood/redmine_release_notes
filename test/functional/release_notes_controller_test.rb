require File.dirname(__FILE__) + '/../test_helper'

class ReleaseNotesControllerPatchTest < ActionController::TestCase
  def setup
    @controller = ReleaseNotesController.new

    # run as an admin
    @user = FactoryGirl.create(:user, :admin => true)
    @request.session[:user_id] = @user.id
  end

  def create_version_with_release_notes
    version = FactoryGirl.create(:version)
    proj = version.project
    unless proj.module_enabled? :release_notes
      proj.enabled_modules << FactoryGirl.build(:enabled_module,
                                                :name => :release_notes)
      proj.save!
    end
    version
  end

  test "don't try to generate without any formats" do
    assert_equal ReleaseNotesFormat.all, [],
      "this test will only work if there are no formats in the db"

    v = create_version_with_release_notes

    get :generate, :id => v.id
    assert_template 'no_formats'
  end
end
