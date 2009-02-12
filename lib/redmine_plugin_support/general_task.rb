require 'rake'
require 'rake/tasklib'

module RedminePluginSupport
  class GeneralTask < ::Rake::TaskLib
    class << self
      def attr_accessor(*names)
        super(*names)
        names.each do |name|
          module_eval "def #{name}() evaluate(@#{name}) end" # Allows use of procs
        end
      end
    end
    
    attr_accessor :name
    
    def initialize(name=:doc)
      define
    end
    
    def define
      # noop
    end
    
    def evaluate(o) # :nodoc:
      case o
      when Proc then o.call
      else o
      end
    end
  end
end


