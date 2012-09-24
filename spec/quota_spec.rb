require "spec_helper"

describe Resque::Plugins::Quota do
  before(:each) do
    @cls = Class.new
    @cls.send :include, Resque::Plugins::Quota
    @cls.class_eval { @queue=:test }
  end
  describe "#requeue" do
    it "should return true for key check method" do
      @cls.quota 1, :expire_in => 30, :requeue => true, :requeue_in => 6
      @cls.requeue?.should be_true
      @cls.requeue_in?.should be_true
    end
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
    end
    it "should run the perform method" do
       @cls.quota 1, :expire_in => 30, :requeue => true, :requeue_in => 5
       expect {@cls.before_perform_quota_check}.to_not raise_error
    end
    it "should not run the perform method" do
       @cls.quota 0, :expire_in => 30, :requeue => false
       @cls.worker_quota=0
       expect {@cls.before_perform_quota_check}.to raise_error
    end
    it "should requeue if specified to" do
      Test=@cls
      Test.quota 1, :expire_in => 30, :requeue => true, :requeue_in => 5
      Test.worker_quota=0
      expect {@cls.before_perform_quota_check}.to raise_error
      Test.should have_scheduled().in(5)
    end
  end
end
