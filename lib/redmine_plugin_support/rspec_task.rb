gem 'rspec'
gem 'rspec-rails'
require 'spec/rake/spectask'

module RedminePluginSupport
  class RspecTask < GeneralTask
    def define

      desc "Run all specs in spec directory (excluding plugin specs)"
      Spec::Rake::SpecTask.new(:spec) do |t|
        t.spec_opts = ['--options', "\"#{RedmineHelper.plugin_root}/spec/spec.opts\""]
        t.spec_files = FileList['spec/**/*_spec.rb']
      end
      
      namespace :spec do
        desc "Run all specs in spec directory with RCov (excluding plugin specs)"
        Spec::Rake::SpecTask.new(:rcov) do |t|
          t.spec_opts = ['--options', "\"#{RedmineHelper.plugin_root}/spec/spec.opts\""]
          t.spec_files = FileList['spec/**/*_spec.rb']
          t.rcov = true
          t.rcov_opts << ["--rails", "--sort=coverage", "--exclude '/var/lib/gems,spec,#{RedmineHelper.redmine_app},#{RedmineHelper.redmine_lib}'"]
        end
        
        desc "Print Specdoc for all specs (excluding plugin specs)"
        Spec::Rake::SpecTask.new(:doc) do |t|
          t.spec_opts = ["--format", "specdoc", "--dry-run"]
          t.spec_files = FileList['spec/**/*_spec.rb']
        end

        desc "Print Specdoc for all specs as HTML (excluding plugin specs)"
        Spec::Rake::SpecTask.new(:htmldoc) do |t|
          t.spec_opts = ["--format", "html:doc/rspec_report.html", "--loadby", "mtime"]
          t.spec_files = FileList['spec/**/*_spec.rb']
        end

        [:models, :controllers, :views, :helpers, :lib].each do |sub|
          desc "Run the specs under spec/#{sub}"
          Spec::Rake::SpecTask.new(sub) do |t|
            t.spec_opts = ['--options', "\"#{RedmineHelper.plugin_root}/spec/spec.opts\""]
            t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
          end
        end
      end

      
      self
    end
    
  end
end
