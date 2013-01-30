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
end
