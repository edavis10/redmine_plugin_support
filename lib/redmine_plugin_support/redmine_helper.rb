module RedminePluginSupport
  class RedmineHelper
    def self.plugin_root
      RedminePluginSupport::Base.options[:plugin_root]
    end

    def self.redmine_root
      File.expand_path(File.dirname(__FILE__) + '/../../../')
    end
    
    def self.redmine_app
      File.expand_path(File.dirname(__FILE__) + '/../../../app')
    end

    def self.redmine_lib
      File.expand_path(File.dirname(__FILE__) + '/../../../lib')
    end

  end
end

