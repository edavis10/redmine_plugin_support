# Testing taked from Rails
require 'rake/testtask'

module RedminePluginSupport
  class TestUnitTask < GeneralTask
    def define

      desc 'Run all unit, functional and integration tests'
      task :test do
        errors = %w(test:units test:functionals test:integration).collect do |task|
          begin
            Rake::Task[task].invoke
            nil
          rescue => e
            task
          end
        end.compact
        abort "Errors running #{errors.to_sentence}!" if errors.any?
      end

      namespace :test do
        Rake::TestTask.new(:units => [:environment, 'db:test:prepare']) do |t|
          t.libs << "test"
          t.pattern = 'test/unit/**/*_test.rb'
          t.verbose = true
        end
        Rake::Task['test:units'].comment = "Run the unit tests in test/unit"

        Rake::TestTask.new(:functionals => [:environment, 'db:test:prepare']) do |t|
          t.libs << "test"
          t.pattern = 'test/functional/**/*_test.rb'
          t.verbose = true
        end
        Rake::Task['test:functionals'].comment = "Run the functional tests in test/functional"

        Rake::TestTask.new(:integration => [:environment, 'db:test:prepare']) do |t|
          t.libs << "test"
          t.pattern = 'test/integration/**/*_test.rb'
          t.verbose = true
        end
        Rake::Task['test:integration'].comment = "Run the integration tests in test/integration"

        Rake::TestTask.new(:benchmark => [:environment, 'db:test:prepare']) do |t|
          t.libs << 'test'
          t.pattern = 'test/performance/**/*_test.rb'
          t.verbose = true
          t.options = '-- --benchmark'
        end
        Rake::Task['test:benchmark'].comment = 'Benchmark the performance tests'

        Rake::TestTask.new(:profile => [:environment, 'db:test:prepare']) do |t|
          t.libs << 'test'
          t.pattern = 'test/performance/**/*_test.rb'
          t.verbose = true
        end
        Rake::Task['test:profile'].comment = 'Profile the performance tests'
      end
      
      self
    end
    
  end
end
