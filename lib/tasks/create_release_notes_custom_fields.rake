task :create_release_notes_custom_fields => :environment do |t|
  require 'redmine'
  puts "Attempting to create the issue custom field: \"Release notes required\"..."
  cf = CustomField.create(:name => "Release notes required",
                    :field_format => "list",
                    :possible_values => ["No - not applicable","Yes - to be done","Yes - done"],
                    :default_value => "Yes - to be done",
                    :editable => true,
                    :visible => true,
                    :is_filter => true)
  cf.type = "IssueCustomField"
  
  if cf.save
    puts "Saved the issue custom field successfully!"
  else
    puts "Failed to save custom field :(\nIs there already a custom field called \"Release notes required\"?"
  end
  
  puts "Attempting to create the version custom field: \"Release notes generated\"..."
  
  cf = nil
  cf = CustomField.create(:name => "Release notes generated",
                    :field_format => "bool",
                    :editable => true,
                    :visible => true)
  cf.type = "VersionCustomField"
  
  if cf.save
    puts "Saved the version custom field successfully!"
  else
    puts "Failed to save custom field :(\nIs there already a custom field called \"Release notes generated\"?"
  end
  
  puts "Finishing task..."
  
end
