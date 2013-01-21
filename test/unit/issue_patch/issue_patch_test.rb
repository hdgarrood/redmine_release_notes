require File.dirname(__FILE__) + '/../../test_helper.rb'

class IssuePatchTest < ActiveSupport::TestCase
  test 'an issue has one release note' do
    i = FactoryGirl.build(:issue)
    assert i.respond_to?(:release_note),
      "i should respond to :release_note"
  end

  test 'issues validate their associated release note' do
    i = FactoryGirl.build(:issue)

    i.release_note = FactoryGirl.build(:release_note,
                                       :text => nil, :issue => nil)
    assert !i.valid?,
      "i should be invalid because its release note is invalid"

    i.release_note.text = "ok, i fixed it"
    assert i.valid?,
      "i should be valid because its release note is valid. Errors:\n" +
      i.errors.full_messages.join(", ")
  end

  test "issues' release notes are completed when the release notes custom " +
    "field's value is the configured field_value_done" do

    cf          = FactoryGirl.create(:release_notes_custom_field)
    settings    = FactoryGirl.create(:release_notes_settings,
                                     :custom_field_id => cf.id)

    todo_value  = settings.value['field_value_todo']
    done_value  = settings.value['field_value_done']

    tracker     = FactoryGirl.create(:tracker,
                                     :custom_fields => [cf])
    issue       = FactoryGirl.create(:issue, :tracker => tracker)
    cv          = FactoryGirl.create(:custom_value,
                                    :customized_type => 'Issue',
                                    :customized_id   => issue.id,
                                    :custom_field => cf,
                                    :value => done_value)

    assert issue.release_notes_done?,
      "issue's release notes should be done when the custom field value" +
      " is the same as the configured field_value_done"

    cv.value = todo_value
    cv.save!

    assert !issue.release_notes_done?,
      "issue's release notes should not be done when the custom field value" +
      " is not the same as the configured field_value_done"
  end

  test "Issue.release_notes_required gives all issues which want release notes" +
    ", including those which have them already" do

    cf          = FactoryGirl.create(:release_notes_custom_field)
    settings    = FactoryGirl.create(:release_notes_settings,
                                     :custom_field_id => cf.id)

    todo_value  = settings.value['field_value_todo']
    done_value  = settings.value['field_value_done']
    not_value   = settings.value['field_value_not_required']

    tracker     = FactoryGirl.create(:tracker,
                                     :custom_fields => [cf])

    # create three issues; one todo, one done, one not required
    issues = [todo_value, done_value, not_value].map do |rn_value|
      issue       = FactoryGirl.create(:issue, :tracker => tracker)
      cv          = FactoryGirl.create(:custom_value,
                                       :customized_type => 'Issue',
                                       :customized_id   => issue.id,
                                       :custom_field => cf,
                                       :value => rn_value)
      issue
    end

    assert_equal issues[0..1], Issue.release_notes_required.to_a,
      "Issue.release_notes_required should give all issues which want release" +
      " notes, including those which have them already"
  end

  test "Issue.release_notes_todo gives all issues which need release notes" +
    " and do not yet have them" do

    cf          = FactoryGirl.create(:release_notes_custom_field)
    settings    = FactoryGirl.create(:release_notes_settings,
                                     :custom_field_id => cf.id)

    todo_value  = settings.value['field_value_todo']
    done_value  = settings.value['field_value_done']
    not_value   = settings.value['field_value_not_required']

    tracker     = FactoryGirl.create(:tracker,
                                     :custom_fields => [cf])

    # create three issues; one todo, one done, one not required
    issues = [todo_value, done_value, not_value].map do |rn_value|
      issue       = FactoryGirl.create(:issue, :tracker => tracker)
      cv          = FactoryGirl.create(:custom_value,
                                       :customized_type => 'Issue',
                                       :customized_id   => issue.id,
                                       :custom_field => cf,
                                       :value => rn_value)
      issue
    end

    assert_equal [issues[0]], Issue.release_notes_todo.to_a,
      "Issue.release_notes_todo should give all issues whose release notes" +
      " need to be done and are not yet done"
  end

  test "Issue.release_notes_done gives all issues whose release notes are done" do

    cf          = FactoryGirl.create(:release_notes_custom_field)
    settings    = FactoryGirl.create(:release_notes_settings,
                                     :custom_field_id => cf.id)

    todo_value  = settings.value['field_value_todo']
    done_value  = settings.value['field_value_done']
    not_value   = settings.value['field_value_not_required']

    tracker     = FactoryGirl.create(:tracker,
                                     :custom_fields => [cf])

    # create three issues; one todo, one done, one not required
    issues = [todo_value, done_value, not_value].map do |rn_value|
      issue       = FactoryGirl.create(:issue, :tracker => tracker)
      cv          = FactoryGirl.create(:custom_value,
                                       :customized_type => 'Issue',
                                       :customized_id   => issue.id,
                                       :custom_field => cf,
                                       :value => rn_value)
      issue
    end

    assert_equal [issues[1]], Issue.release_notes_done.to_a,
      "Issue.release_notes_done should give all issues whose release notes" +
      " are done"
  end
end
