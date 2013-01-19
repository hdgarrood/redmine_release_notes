require 'faker'

FactoryGirl.define do
  factory :issue do
    subject { Faker::Company.bs }
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
    name { Faker::Lorem.words(1).first[0..20] }
  end

  factory :issue_status, :aliases => [:status] do
    name { Faker::Lorem.words(2).join(" ")[0..20] }
  end

  factory :project do
    name                  { Faker::Lorem.words(1).first[0..20] }
    identifier            { name.downcase }
    enabled_module_names  %w(issue_tracking)
  end

  factory :enabled_module do
    name { Faker::Lorem.words(1).first[0..20] }
  end

  factory :user, :aliases => [:author] do
    firstname { Faker::Name.first_name }
    lastname  { Faker::Name.last_name }
    login     { "#{firstname}.#{lastname}".downcase.gsub(/[^0-9a-z]/, '') }
    mail      { "#{login}@example.com" }
  end

  factory :tracker do
    name { Faker::Lorem.words(1).first[0..20] }
  end

  factory :release_note do
    text { Faker::Lorem.sentences.join(" ") }
    issue
  end

  factory :issue_custom_field do
    name         "Reported in version"
    field_format "text"

    factory :release_notes_custom_field do
      name            "Release notes"
      field_format    "list"
      possible_values "Done\nTodo\nNo"
    end
  end

  factory :custom_value do
    association :customized, :factory => :issue
    association :custom_field, :factory => :issue_custom_field
    value "hello"
  end

  factory :release_notes_settings, :class => Setting do
    ignore do
      issue_required_field_id 0
    end

    name "plugin_redmine_release_notes"

    after(:build) do |s, e|
      s.value ||= {
        'issue_required_field_id'    => e.issue_required_field_id,
        'default_generation_format'  => "Textile",
        'field_value_done'           => "Done",
        'field_value_todo'           => "Todo",
        'field_value_not_required'   => "No"
      }.with_indifferent_access
    end
  end
end
