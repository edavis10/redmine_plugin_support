# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{redmine_plugin_support}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Davis"]
  s.date = %q{2009-03-06}
  s.description = %q{FIX (describe your package)}
  s.email = ["edavis@littlestreamsoftware.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "features/development.feature", "features/steps/common.rb", "features/steps/env.rb", "lib/redmine_plugin_support.rb", "lib/redmine_plugin_support/cucumber_task.rb", "lib/redmine_plugin_support/general_task.rb", "lib/redmine_plugin_support/rdoc_task.rb", "lib/redmine_plugin_support/redmine_helper.rb", "lib/redmine_plugin_support/release_task.rb", "lib/redmine_plugin_support/rspec_task.rb", "script/console", "script/destroy", "script/generate", "spec/redmine_plugin_support_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{FIX (url)}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{redmine_plugin_support}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{FIX (describe your package)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
