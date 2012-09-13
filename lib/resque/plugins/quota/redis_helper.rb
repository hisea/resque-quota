require 'resque'

module Resque
  module Plugins
    module Quota
      module RedisHelper
        def set_key(key,value)
          Resque.redis.set key,value
        end
        def get_key(key)
          Resque.redis.get key
        end
        def decr_key_by(key,value)
          Resque.redis.decrby key,value
        end
        def expire_key(key,ttl)
          Resque.redis.expire key,ttl
        end
        def exist_key?(key)
          Resque.redis.exists key
        end
      end
    end
  end
end
