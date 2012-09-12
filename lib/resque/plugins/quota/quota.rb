require_relative "redis_helper"
module Resque
  module Plugins
    module Quota
      VERSION = "0.0.1"
      module InstanceMethods
      end
      module ClassMethods
        include Resque::Plugins::Quota::ResqueHelper
        def quota(value)

        end
        def refresh_period(ttl)
          
        end
        def woker_quota_key
          "#{Socket.gethostname}:#{Process.pid}"
        end
        
        def default_quota_key
          
        end
        def default_refresh_period_key
          
        end

        def before_perform_quota_check(*args)
          #false
          #raise Resque::Job::DontPerform
        end
      end
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end
    end
  end
end
