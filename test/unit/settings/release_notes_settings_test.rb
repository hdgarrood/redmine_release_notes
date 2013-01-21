require File.dirname(__FILE__) + '/../../test_helper'

class ReleaseNotesSettingsTest < ActiveSupport::TestCase
  test '#find gets settings from Setting' do
    Setting.expects(:plugin_redmine_release_notes).once.returns({})
    ReleaseNotesSettings.find
  end

  test 'can set attributes with #update' do
    s = ReleaseNotesSettings.find
    s.update(:custom_field_id => 2)

    assert_equal 2, s.custom_field_id
  end

  test 'has defaults' do
    defaults = ReleaseNotesSettings.defaults
    assert_equal Hash, defaults.class
  end

  test 'delegates saving to Setting if valid' do
    settings = ReleaseNotesSettings.find
    settings.stubs(:valid?).returns(true)

    defaults = ReleaseNotesSettings.defaults
    Setting.expects(:plugin_redmine_release_notes=).with(defaults)

    settings.save
  end

  test 'does not save if invalid' do
    settings = ReleaseNotesSettings.find
    settings.stubs(:valid?).returns(false)

    assert_equal false, settings.save
  end

  test '#save returns true when valid' do
    settings = ReleaseNotesSettings.find
    settings.stubs(:valid?).returns(true)

    Setting.stubs(:plugin_redmine_release_notes=).returns(true)
    
    assert_equal true, settings.save
  end
end

