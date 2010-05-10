 $:.unshift(File.dirname(__FILE__)) unless
   $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rake'
require 'rake/tasklib'
 
require 'redmine_plugin_support/redmine_helper'
require 'redmine_plugin_support/general_task'
require 'redmine_plugin_support/environment_task'
require 'redmine_plugin_support/database_task'
require 'redmine_plugin_support/cucumber_task'
require 'redmine_plugin_support/metrics_task'
require 'redmine_plugin_support/rdoc_task'
require 'redmine_plugin_support/release_task'
require 'redmine_plugin_support/rspec_task'
require 'redmine_plugin_support/stats_task'
require 'redmine_plugin_support/test_unit_task'

module RedminePluginSupport
  VERSION = '0.0.4'

  @@options = { }

  class Base
    include Singleton

    attr_accessor :project_name
    attr_accessor :tasks
    attr_accessor :plugin_root
    attr_accessor :redmine_root
    attr_accessor :default_task

    attr_accessor :plugin
  

    # :plugin_root => File.expand_path(File.dirname(__FILE__))
    def self.setup(options = { }, &block)
      plugin = self.instance
      plugin.project_name = 'undefined'
      plugin.tasks = [:db, :doc, :spec, :cucumber, :release, :clean, :test, :stats]
      plugin.plugin_root = '.'
      plugin.redmine_root = ENV["REDMINE_ROOT"] || File.expand_path(File.dirname(__FILE__) + '/../../../')
      plugin.default_task = :doc

      plugin.instance_eval(&block)

      RedminePluginSupport::EnvironmentTask.new(:environment)

      plugin.tasks.each do |task|
        case task
        when :db
          RedminePluginSupport::DatabaseTask.new(:db)
        when :doc
          RedminePluginSupport::RDocTask.new(:doc)
        when :spec
          RedminePluginSupport::RspecTask.new(:spec)
        when :test
          RedminePluginSupport::TestUnitTask.new(:test)
        when :cucumber
          RedminePluginSupport::CucumberTask.new(:features)
        when :release
          RedminePluginSupport::ReleaseTask.new(:release)
        when :stats
          RedminePluginSupport::StatsTask.new(:stats)
        when :metrics
          RedminePluginSupport::MetricsTask.new(:metrics)
        when :clean
          require 'rake/clean'
          CLEAN.include('**/semantic.cache', "**/#{plugin.project_name}.zip", "**/#{plugin.project_name}.tar.gz")
        end
      end
      
      task :default => plugin.default_task

    end
  end

end
