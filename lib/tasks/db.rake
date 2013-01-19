require 'yaml'

namespace :db do
  namespace :test do
    task(:truncate => :environment) do
      if ENV['RAILS_ENV'] == 'test'
        ActiveRecord::Base.establish_connection
        case ActiveRecord::Base.connection_config[:adapter]
        when "mysql"
          ActiveRecord::Base.connection.tables.each do |table|
            ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
          end
        when "sqlite", "sqlite3"
          ActiveRecord::Base.connection.tables.each do |table|
            ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
            ActiveRecord::Base.connection.execute(
              "DELETE FROM sqlite_sequence where name='#{table}'")
          end                                                                                                                               
          ActiveRecord::Base.connection.execute("VACUUM")
        end
      else
        system("RAILS_ENV=test rake db:test:truncate")
      end
    end
  end
end
