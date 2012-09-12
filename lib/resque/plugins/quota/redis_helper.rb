module Resque
  module Plugins
    module RedisHelper
        def set_key(value)
          Resque.redis.set self.key,value
        end
        def get_key
          Resque.redis.get self.key
        end
        def decr_key_by(value)
          Resque.redis.decrby self.key,value
        end
    end
  end
end
