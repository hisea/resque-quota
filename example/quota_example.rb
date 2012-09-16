require 'resque-quota'
class QuotaExample
  include Resque::Plugins::Quota
  quota 1, :expire_in => 30, :requeue => true, :requeue_in => 5
  @queue=:test
  def self.perform(name,name2)
    puts "Before: #{worker_quota_key}: " + worker_quota
    puts "Hello #{name}"
    decr_quota_by(1)
    puts "After: #{worker_quota_key}: "+worker_quota
  end
end
