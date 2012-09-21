require 'rubygems'
require 'bundler/setup'

require "resque"
require "resque-quota"
require 'mock_redis'
require 'resque_spec'
RSpec.configure do |config|
  # some (optional) config here
  Resque.redis = MockRedis.new
end

