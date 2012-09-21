require_relative "redis_helper"
require 'resque_scheduler'
require 'socket'
module Resque
  module Plugins
    module Quota
      VERSION = "0.0.1"
      module InstanceMethods
      end
      module ClassMethods
        include Resque::Plugins::Quota::RedisHelper

        [:default_expiry,:default_quota,:requeue,:requeue_in].each do |method|
          define_method "#{method}_key" do
            "resque:quota:#{self.name}:#{method}"
          end
          define_method "#{method}=" do |value|
            self.set_key self.send("#{method}_key"), value
          end

          define_method "#{method}" do 
            self.get_key self.send("#{method}_key")
          end
          define_method "#{method}?" do
            self.exist_key?(self.send "#{method}_key")
          end
        end
      
        def quota(value,options ={})
          default_options = { 
            :expire_in => 3600,
            :requeue => false,
            :requeue_in => 10
          }
          options.merge(default_options)
          self.default_quota= value
          self.default_expiry= options[:expire_in] 
          if options[:requeue]
            self.requeue= true 
            self.requeue_in= options[:requeue_in] 
          end
        end


        def worker_quota=(value)
          is_new_key = !self.exist_key?(self.worker_quota_key)
          self.set_key self.worker_quota_key,value
          self.expire_key self.worker_quota_key,self.default_expiry if is_new_key
        end
        def worker_quota
          unless self.exist_key?(self.worker_quota_key)
            self.worker_quota= self.default_quota          
          end
          self.get_key self.worker_quota_key
        end

        def decr_quota_by(value)
          self.decr_key_by self.worker_quota_key,value
        end
        def worker_quota_key
          "#{Socket.gethostname}:#{Process.ppid}:#{self.name}"
        end
        
        def before_perform_quota_check(*args)
          puts "Before: #{worker_quota_key}: #{worker_quota}"        
          puts "default expiry: #{self.default_expiry}"
          if self.worker_quota.to_i <= 0
            if self.requeue? && self.requeue == "true"
              Resque.enqueue_in(self.requeue_in.to_i,self,*args)
            end
            raise Resque::Job::DontPerform 
          end
        end
      end
      def self.included(base)
        base.extend ClassMethods
        #base.send :include, InstanceMethods
      end
    end
  end
end
