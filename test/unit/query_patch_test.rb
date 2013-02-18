require File.dirname(__FILE__) + '/../test_helper.rb'

class QueryPatchTest < ActiveSupport::TestCase
  def setup
    # make an admin user
    @user = FactoryGirl.create(:user, :admin => true)
    # make them the current user
    User.stubs(:current).returns(@user)
  end

  # create a project with 3 issues with release notes todo, 4 done, and 5
  # not required
  def make_a_project_with_some_issues_and_release_notes
    project = FactoryGirl.create(:project_with_release_notes)
    [[3, 'todo'], [4, 'done'], [5, 'not_required']].map do |n, status|
      n.times do
        issue = FactoryGirl.create(:issue, :project => project)
        issue.build_release_note
        issue.release_note.status = status
        issue.release_note.text = 'LULZ' # so that it's valid
        issue.release_note.save!
      end
    end
    project
  end

  test 'release notes filter available when project has release notes' +
  ' enabled' do
    project = FactoryGirl.create(:project,
                                 :enabled_module_names => %w(issue_tracking
                                                             release_notes))
    query = FactoryGirl.build(:issue_query, :project => project)

    assert query.available_filters.include?("release_notes")
  end

  test 'release notes filter not available when no project' do
    query = FactoryGirl.build(:issue_query)
    assert !query.available_filters.include?('release_notes')
  end

  test 'release notes filter not available when release notes module ' +
  'disabled' do
    project = FactoryGirl.create(:project,
                                 :enabled_module_names => %w(issue_tracking))
    query = FactoryGirl.build(:issue_query, :project => project)

    assert !query.available_filters.include?("release_notes")
  end

  test 'issue_count returns correct value' do
    project = make_a_project_with_some_issues_and_release_notes

    query = FactoryGirl.build(:issue_query, :project => project, :user => @user)
    assert query.valid?
    assert_equal 12, query.issue_count

    query = FactoryGirl.build(:issue_query, :project => project, :user => @user)
    query.add_filter('release_notes', '=', %w(todo))
    assert query.valid?
    assert_equal 3, query.issue_count

    query = FactoryGirl.build(:issue_query, :project => project, :user => @user)
    query.add_filter('release_notes', '=', %w(todo done))
    assert query.valid?
    assert_equal 7, query.issue_count
  end

  test 'issues may be grouped by release notes' do
    project = make_a_project_with_some_issues_and_release_notes
    query = FactoryGirl.build(:issue_query,
                              :project => project,
                              :group_by => 'release_notes')

    assert query.grouped?
    assert_equal({'todo' => 3, 'done' => 4, 'not_required' => 5},
      query.issue_count_by_group)
  end
end
