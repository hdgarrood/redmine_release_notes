task :create_release_notes_custom_fields => :environment do |t|
  require 'redmine'
  cf = CustomField.create(:name => "Release notes required",
                    :field_format => "list",
                    :possible_values => ["No - not applicable","Yes - to be done","Yes - done"],
                    :default_value => "Yes - to be done",
                    :editable => true,
                    :visible => true,
                    :is_filter => true)
  cf.type = "IssueCustomField"
  puts "Failed to save custom field :(\nIs there already a custom field called \"Release notes required\"?" unless cf.save
end
