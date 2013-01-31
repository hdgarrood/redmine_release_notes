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
  end

  factory :project do
    sequence(:name)       {|n| "my-project-#{n}"}
    identifier            { name.downcase }
    enabled_module_names  %w(issue_tracking)
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
end
