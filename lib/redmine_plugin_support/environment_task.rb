module RedminePluginSupport
  class EnvironmentTask < GeneralTask
    def define
      task :environment do
        require(File.join(RedmineHelper.redmine_root + '/config', 'environment'))
      end
    end
  end
end
