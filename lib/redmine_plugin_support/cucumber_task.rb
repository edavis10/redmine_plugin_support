require 'cucumber/rake/task'

module RedminePluginSupport
  class CucumberTask < GeneralTask
    def define
      # TODO: Requires webrat to be installed as a plugin....
      Cucumber::Rake::Task.new(:features) do |t|
        t.cucumber_opts = "--format pretty"
      end

      namespace :features do
        Cucumber::Rake::Task.new(:rcov) do |t|
          t.cucumber_opts = "--format pretty" 
          t.rcov = true
          t.rcov_opts << ["--rails", "--sort=coverage", "--exclude '/var/lib/gems,spec,#{RedmineHelper.redmine_app},#{RedmineHelper.redmine_lib},step_definitions,features/support'"]
        end
      end
    end

  end
end
