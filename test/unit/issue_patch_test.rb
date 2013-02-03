require File.dirname(__FILE__) + '/../test_helper.rb'

class IssuePatchTest < ActiveSupport::TestCase
  test 'an issue has one release note' do
    i = FactoryGirl.build(:issue)
    assert i.respond_to?(:release_note),
      "i should respond to :release_note"
  end

  test 'issues validate their associated release note' do
    i = FactoryGirl.build(:issue)
    i.build_release_note
    i.release_note.stubs(:valid?).returns(false)
    
    assert !i.valid?,
      "i should be invalid because its release note is invalid"

    i.release_note.stubs(:valid?).returns(true)
    assert i.valid?,
      "i should be valid because its release note is valid"
  end

  test "issues' release notes are done when they're done" do 
    release_note = FactoryGirl.build(:release_note)
    release_note.status = 'done'
    issue = release_note.issue

    assert issue.release_notes_done?,
      "issue's release notes should be done when release note status == 'done'"

    release_note.status = 'todo'
    assert !issue.release_notes_done?,
      "issue's release notes should not be done when release notes status != 'done'"
  end

  test "Issue.release_notes_required gives all issues which want release notes" +
    ", including those which have them already" do
    issues = {}
    %w(todo done not_required).each do |status|
      rn  = FactoryGirl.create(:release_note, :status => status)
      issues[status] = rn.issue
    end

    assert Issue.release_notes_required.include?(issues['todo'])
    assert Issue.release_notes_required.include?(issues['done'])
    assert !Issue.release_notes_required.include?(issues['not_required'])
  end

  test "Issue.release_notes_todo gives all issues which need release notes" +
    " and do not yet have them" do
    issues = {}
    %w(todo done not_required).each do |status|
      rn  = FactoryGirl.create(:release_note, :status => status)
      issues[status] = rn.issue
    end

    assert Issue.release_notes_todo.include?(issues['todo'])
    assert !Issue.release_notes_todo.include?(issues['done'])
    assert !Issue.release_notes_todo.include?(issues['not_required'])
  end

  test "Issue.release_notes_done gives all issues whose release notes are done" do
    issues = {}
    %w(todo done not_required).each do |status|
      rn  = FactoryGirl.create(:release_note,
                               :status => status)
      issues[status] = rn.issue
    end

    assert !Issue.release_notes_done.include?(issues['todo'])
    assert Issue.release_notes_done.include?(issues['done'])
    assert !Issue.release_notes_done.include?(issues['not_required'])
  end
end
