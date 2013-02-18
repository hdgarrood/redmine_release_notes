# Copyright (C) 2012-2013 Harry Garrood
# This file is a part of redmine_release_notes.

# redmine_release_notes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.

# redmine_release_notes is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.

# You should have received a copy of the GNU General Public License along with
# redmine_release_notes. If not, see <http://www.gnu.org/licenses/>.

require 'yaml'

namespace :redmine do
  namespace :plugins do
    namespace :release_notes do
      desc 'run all tests for release notes plugin'
      task :test => 'redmine:plugins:release_notes:test:all'

      namespace :test do
        def assumes_migrated_test_task(type)
          Rake::TestTask.new(type) do |t|
            t.libs << 'test'

            test_subdir = case type
            when :units
              'unit'
            when :functionals
              'functional'
            when :integration
              'integration'
            when :all
              '{unit,functional,integration}'
            end

            t.pattern =
              "plugins/redmine_release_notes/test/#{test_subdir}/**/*_test.rb"
          end
        end

        desc 'run unit tests'
        assumes_migrated_test_task :units

        desc 'run functional tests'
        assumes_migrated_test_task :functionals

        desc 'run integration tests'
        assumes_migrated_test_task :integration

        desc 'run all tests'
        assumes_migrated_test_task :all
      end

      task :load_default_formats => :environment do
        fail 'you already have some formats! run with FORCE to force' unless
          ReleaseNotesFormat.count == 0 || ENV['FORCE']

        if File.exist?("plugins/redmine_release_notes/config/formats.yml")
          # this person was using 1.2.0
          upgrading_from_120 = true
          source_file = "plugins/redmine_release_notes/config/formats.yml"
        else
          source_file = "plugins/redmine_release_notes/db/seeds.yml"
        end

        YAML.load_file(source_file).
          inject({}) {|h, (k,v)| h[k] = v; h[k][:name] ||= k.to_s; h }.
          values.each { |v| ReleaseNotesFormat.create!(v) }

        if upgrading_from_120
          puts "formats were successfully loaded into DB."
          puts "you may want to delete #{source_file} now."
        end
      end
    end
  end
end
