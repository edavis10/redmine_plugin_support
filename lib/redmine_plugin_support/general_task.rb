require 'rake'
require 'rake/tasklib'

module RedminePluginSupport
  class GeneralTask < ::Rake::TaskLib
    attr_accessor :name
    
    def initialize(name=:noop)
      define
    end
    
    def define
      # noop
    end
    
  end
end


