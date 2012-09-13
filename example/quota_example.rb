require 'resque-quota'
class QuotaExample
  include Resque::Plugins::Quota

  @queue=:test
  def self.perform
    puts "Hello"
  end
end
