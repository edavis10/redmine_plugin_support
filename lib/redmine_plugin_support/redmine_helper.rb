module RedminePluginSupport
  class RedmineHelper
    def self.plugin_root
      RedminePluginSupport::Base.instance.plugin_root
    end

    def self.redmine_root
      RedminePluginSupport::Base.instance.redmine_root
    end
    
    def self.redmine_app
      File.expand_path(RedminePluginSupport::Base.instance.redmine_root + '/app')
    end

    def self.redmine_lib
      File.expand_path(RedminePluginSupport::Base.instance.redmine_root + '/lib')
    end

  end
end

