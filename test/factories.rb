FactoryGirl.define do
  factory :issue do
    subject 'not working'
    project
    author
    priority
    status

    after(:build) do |i|
      i.tracker ||= FactoryGirl.create(:tracker,
                                       :projects => [i.project])
    end
  end

  factory :issue_priority, :aliases => [:priority] do
    sequence(:name) {|n| "priority-#{n}"}
  end

  factory :issue_status, :aliases => [:status] do
    sequence(:name) {|n| "issue-status-#{n}"}
    is_closed false
  end

  factory :project do
    sequence(:name)       {|n| "my-project-#{n}"}
    identifier            { name.downcase }
    enabled_module_names  %w(issue_tracking)

    factory :project_with_release_notes do
      enabled_module_names %w(issue_tracking release_notes)
    end
  end

  factory :enabled_module do
    name 'gantt'
    project
  end

  factory :user, :aliases => [:author] do
    firstname 'joe'
    lastname  'bloggs'
    sequence(:login) {|n| "#{firstname}.#{lastname}.#{n}".downcase.gsub(/[^0-9a-z]/, '') }
    mail { "#{login}@example.com" }
  end

  factory :tracker do
    sequence(:name) {|n| "tracker-#{n}"}
  end

  factory :release_note do
    text 'no longer broken'
    issue
  end

  factory :role do
    sequence(:name) {|n| "role-#{n}"}
  end

  factory :version do
    sequence(:name) {|n| "0.0.#{n}"}
    project

    factory :version_with_release_notes do
      association :project, :factory => :project_with_release_notes
    end
  end

  factory :release_notes_format do
    sequence(:name) {|n| "format-#{n}"}
    header 'Release notes for %{version}'
    start ''
    each_issue '* %{release_notes}'

    # hack -- we can't write a literal 'end' cuz it's a Ruby keyword
    sequence(:end) {|n| '' }
  end

  factory :issue_query do
    sequence(:name) {|n| "query-#{n}"}
  end

  factory :query do
    sequence(:name) {|n| "query-#{n}"}
  end
end
