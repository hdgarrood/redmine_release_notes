require File.dirname(__FILE__) + '/../test_helper.rb'

class QueryPatchTest < ActiveSupport::TestCase
  # create a project with 3 issues with release notes todo, 4 done, and 5
  # not required
  def make_a_project_with_some_issues_and_release_notes
    project = FactoryGirl.create(:project,
                                 :enabled_module_names => %w(issue_tracking
                                                             release_notes))
    [[3, 'todo'], [4, 'done'], [5, 'not_required']].map do |n, status|
      n.times do
        issue = FactoryGirl.create(:issue, :project => project)
        issue.build_release_note
        issue.release_note.status = status
        issue.release_note.text = 'LULZ' # so that it's valid
        issue.save!
      end
    end
    project
  end

  def make_a_valid_query(project)
    query = IssueQuery.new(:project => project)
    query.stubs(:valid?).returns(true)
    query
  end

  test 'release notes filter available when project has release notes' +
  ' enabled' do
    project = FactoryGirl.create(:project,
                                 :enabled_module_names => %w(issue_tracking
                                                             release_notes))
    query = IssueQuery.new(:project => project)

    assert query.available_filters.include?("release_notes")
  end

  test 'release notes filter not available when no project' do
    assert !IssueQuery.new.available_filters.include?('release_notes')
  end

  test 'release notes filter not available when release notes module ' +
  'disabled' do
    project = FactoryGirl.create(:project,
                                 :enabled_module_names => %w(issue_tracking))
    query = IssueQuery.new(:project => project)

    assert !query.available_filters.include?("release_notes")
  end

  test 'issue_count returns correct value' do
    project = make_a_project_with_some_issues_and_release_notes

    query = make_a_valid_query(project)
    assert_equal 12, query.issue_count

    query = make_a_valid_query(project)
    query.add_filter('release_notes', '=', %w(todo))
    assert_equal 3, query.issue_count

    query = make_a_valid_query(project)
    query.add_filter('release_notes', '=', %w(todo done))
    assert_equal 7, query.issue_count
  end

  test 'issues returns correct issues' do
    project = make_a_project_with_some_issues_and_release_notes
    # todo
  end
end
