require "spec_helper"

describe Resque::Plugins::Quota do
  before(:each) do
    @cls = Class.new
    @cls.send :include, Resque::Plugins::Quota
  end
  describe "#quota" do
    it "should setup class for values" do
      @cls.quota 1
      @cls.default_quota.to_i.should == 1
    end
    it "should set up optional values" do
      @cls.quota 1, :expire_in => 30, :requeue => true, :requeue_in => 5
      @cls.default_quota.to_i.should == 1
      @cls.default_expiry.to_i.should == 30
      @cls.requeue.should == "true"
      @cls.requeue_in.to_i.should == 5
    end
  end
  describe "#worker_quota" do
    it "should copy the default quota for existing and non-existing quota" do
      @cls.quota 1, :expire_in => 30, :requeue => true, :requeue_in => 5
      @cls.worker_quota.to_i.should == 1
      Resque.redis.ttl(@cls.worker_quota_key).should == 30
      @cls.worker_quota.to_i.should == 1      
    end
  end
  describe "#worker_quota=" do
    it "should set non existed value" do
      @cls.quota 1, :expire_in => 30, :requeue => true, :requeue_in => 5
      @cls.worker_quota= 2
      @cls.worker_quota.to_i.should == 2
      Resque.redis.ttl(@cls.worker_quota_key).should == 30
      @cls.worker_quota=3
      @cls.worker_quota.to_i.should == 3 
    end
  end
  describe "#before_perform_quota_check" do
    before do
      ResqueSpec.reset!
      @cls.class_eval do
        @queue = :test
        @@var = 1
        define_method :perform do
          @@var = 10
        end
      end
    end
    it "should run the perform method" do
      with_resque do
        Resque.enqueue(@cls)
      end
      @cls.class_eval{ @@var }.should == 10
    end
  end
end
