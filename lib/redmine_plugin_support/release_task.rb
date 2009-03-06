module RedminePluginSupport
  class ReleaseTask < GeneralTask
    def define
      namespace :release do
        desc "Create a zip archive"
        task :zip => [:clean] do
          sh "git archive --format=zip --prefix=#{Base.instance.project_name}/ HEAD > #{Base.instance.project_name}.zip"
        end

        desc "Create a tarball archive"
        task :tarball => [:clean] do
          sh "git archive --format=tar --prefix=#{Base.instance.project_name }/ HEAD | gzip > #{Base.instance.project_name}.tar.gz"
        end
      end
    end

  end
end
