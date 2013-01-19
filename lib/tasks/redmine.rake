# differences to standard Redmine plugin tests:
#   executes db:test:purge instead of db:test:prepare
#   verbose is set to false
#   only does release notes plugin

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
    end
  end
end
