require 'resque'
require 'resque_scheduler'
require 'socket'
module Resque
  module Plugins
    module Quota
      VERSION = "0.0.1"
      module InstanceMethods
      end
      module ClassMethods
        include Resque::Helpers

        [:default_expiry,:default_quota,:requeue,:requeue_in].each do |method|
          define_method "#{method}_key" do
            "resque:quota:#{self.name}:#{method}"
          end
          define_method "#{method}=" do |value|
            redis.set self.send("#{method}_key"), value
          end

          define_method "#{method}" do 
            redis.get self.send("#{method}_key")
          end
          define_method "#{method}?" do
            redis.exists(self.send "#{method}_key")
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
          is_new_key = !redis.exists(self.worker_quota_key)
          redis.set self.worker_quota_key,value
          redis.expire self.worker_quota_key,self.default_expiry if is_new_key
        end
        def worker_quota
          self.worker_quota= self.default_quota unless redis.exists(self.worker_quota_key)
          redis.get self.worker_quota_key
        end

        def decr_quota_by(value)
          redis.decrby self.worker_quota_key,value
        end
        def worker_quota_key
          "#{Socket.gethostname}:#{Process.ppid}:#{self.name}"
        end
        
        def before_perform_quota_check(*args)
          if self.worker_quota.to_i <= 0
            if self.requeue? && self.requeue_in?
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
