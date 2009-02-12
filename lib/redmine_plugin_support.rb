 $:.unshift(File.dirname(__FILE__)) unless
   $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rake'
require 'rake/tasklib'
 
require 'redmine_plugin_support/redmine_helper'
require 'redmine_plugin_support/general_task'
require 'redmine_plugin_support/cucumber_task'
require 'redmine_plugin_support/rdoc_task'
require 'redmine_plugin_support/release_task'
require 'redmine_plugin_support/rspec_task'

module RedminePluginSupport
  VERSION = '0.0.1'

  @@options = { }

  class Base
    # :plugin_root => File.expand_path(File.dirname(__FILE__))
    def self.setup(options = { })
      @@options = { 
        :project_name => 'undefined',
        :tasks => [:doc, :spec, :cucumber, :release, :clean],
        :plugin_root => '.',
        :default => :doc
      }.merge(options)

      @@options[:tasks].each do |task|
        case task
        when :doc
          RedminePluginSupport::RDocTask.new(:doc)
        when :spec
          RedminePluginSupport::RspecTask.new(:spec)
        when :cucumber
          RedminePluginSupport::CucumberTask.new(:features)
        when :release
          RedminePluginSupport::ReleaseTask.new(:release)
        when :clean
          require 'rake/clean'
          CLEAN.include('**/semantic.cache', "**/#{@@options[:project_name]}.zip", "**/#{@@options[:project_name]}.tar.gz")
        end
      end
      
      task :default => @@options[:default]

    end
    
    def self.options
      @@options
    end

  end

end
