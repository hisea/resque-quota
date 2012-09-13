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
          default_options = { :expire_in => 3600 }
          options.merge(default_options)
          default_quota = value
          default_expiry = options[:expire_in] 
        end

        [:default_expiry,:default_quota].each do |method|
          define_method "#{method}_key" do
            "#{self.name}:#{method}"
          end
          define_method "#{method}=" do |value|
            set_key self.send("#{method}_key"), value
          end

          define_method "#{method}" do 
            get_key self.send("#{method}_key")
          end
        end

        def worker_quota=(value)
          is_new_key = !exist_key?(worker_quota_key)
          set_key worker_quota_key,value
          expire_key worker_quota_key,default_expiry if is_new_key
        end
        def worker_quota
          self.worker_quota= default_quota unless exist_key?(worker_quota_key)
          get_key worker_quota_key
        end

        def decr_quota_by(value)
          decr_key_by self.worker_quota_key,value
        end
        def worker_quota_key
          "#{Socket.gethostname}:#{Process.pid}:quota"
        end
        
        def before_perform_quota_check(*args)
          #raise "error"
          raise Resque::Job::DontPerform if worker_quota.to_i <= 0
        end
      end
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end
    end
  end
end
