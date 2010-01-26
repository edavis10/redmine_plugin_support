module RedminePluginSupport
  class MetricsTask < GeneralTask
    def define
      require 'metric_fu'

      namespace :metrics do
        desc "Check the code against the rails_best_practices"
        task :rails_best_practices do
          system("rails_best_practices #{RedmineHelper.plugin_root}")
        end
      end
    end
  end
end
