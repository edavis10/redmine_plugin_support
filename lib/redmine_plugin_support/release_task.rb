module RedminePluginSupport
  class ReleaseTask < GeneralTask
    def define
      desc "Create packages"
      task :release => ['release:zip', 'release:tarball']
      
      namespace :release do
        desc "Create a zip archive"
        task :zip do
          sh "git archive --format=zip --prefix=#{Base.instance.project_name}/ HEAD > #{Base.instance.project_name}.zip"
        end

        desc "Create a tarball archive"
        task :tarball do
          sh "git archive --format=tar --prefix=#{Base.instance.project_name }/ HEAD | gzip > #{Base.instance.project_name}.tar.gz"
        end
      end
    end

  end
end
