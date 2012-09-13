require 'resque-quota'
class QuotaExample
  include Resque::Plugins::Quota
  quota 1, :expire_in => 30
  @queue=:test
  def self.perform
    puts "Hello"
    puts "Before: #{worker_quota_key}" + worker_quota
    decr_quota_by(1)
    puts "After: #{worker_quota_key}"+worker_quota
  end
end
