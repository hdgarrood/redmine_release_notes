require File.dirname(__FILE__) + '/../test_helper'

class ReleaseNotesFormatsControllerTest < ActionController::TestCase
  def setup
    @controller = ReleaseNotesFormatsController.new
  end

  def run_as_non_admin!
    @user = FactoryGirl.create(:user, :admin => false)
    @request.session[:user_id] = @user.id
  end

  test 'may not do anything with formats if not admin' do
    run_as_non_admin!

    get :new
    assert_response 403

    format = FactoryGirl.build(:release_notes_format)
    post :create, :release_notes_format => format
    assert_response 403
    assert_nil ReleaseNotesFormat.find_by_name(format.name)

    format.save!
    get :edit, :id => format.id
    assert_response 403

    [:update, :preview].each do |action|
      put action, :id => format.id, :release_notes_format => format
      assert_response 403
    end
  end
end
