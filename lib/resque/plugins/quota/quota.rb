require_relative "redis_helper"
require 'socket'
module Resque
  module Plugins
    module Quota
      VERSION = "0.0.1"
      module InstanceMethods
      end
      module ClassMethods
        include Resque::Plugins::Quota::RedisHelper
        def quota(value,options ={})
          default_options = { :refresh_in => 3600 }
          options.merge!(default_options)
          set_key default_qouta_key, value
          set_key default_refresh_key, options[:refresh_in] 
        end
        def worker_quota_key
          "#{Socket.gethostname}:#{Process.pid}:quota"
        end
        
        def default_quota_key
          "#{self.name}:default_quota"
        end
        def default_refresh_key
          "#{self.name}:default_refresh_period"
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
