require File.expand_path('../test_helper', __FILE__)

class StatsdTest < Test::Unit::TestCase
  
  def setup
    Statsd.host = 'localhost'
    Statsd.port = 8125
    super
  end
  
  context "timing" do
    
    should "send with ms" do
      expected_send('test.stat:23|ms')
      Statsd.timing('test.stat', 23)
    end
    
    should "log when sampled" do
      fake_rand(0.09)
      expected_send('test.stat:23|ms@0.1')
      Statsd.timing('test.stat', 23, 0.1)
    end
    
    should "not log when not sampled" do
      fake_rand(0.11)
      expect_nothing
      Statsd.timing('test.stat', 23, 0.1)      
    end
    
  end
  
  context "increment" do
    
    should "send number" do
      expected_send('test.stat:1|c')
      Statsd.increment('test.stat')
    end

    should "log when sampled" do
      fake_rand(0.09)
      expected_send('test.stat:1|c@0.1')
      Statsd.increment('test.stat', 0.1)
    end

    should "not log when not sampled" do
      fake_rand(0.11)
      expect_nothing
      Statsd.increment('test.stat', 0.1)      
    end
        
  end
  
  context "decrement" do
    
    should "send number" do
      expected_send('test.stat:-1|c')
      Statsd.decrement('test.stat')
    end

    should "log when sampled" do
      fake_rand(0.09)
      expected_send('test.stat:-1|c@0.1')
      Statsd.decrement('test.stat', 0.1)
    end

    should "not log when not sampled" do
      fake_rand(0.11)
      expect_nothing
      Statsd.decrement('test.stat', 0.1)      
    end
    
  end
  
  context "host" do
    
    should "be gettable and settable" do
      Statsd.host = 'statsd-01'
      assert_equal 'statsd-01', Statsd.host
    end
    
  end
  
  context "port" do

    should "be gettable and settable" do
      Statsd.port = 1234
      assert_equal 1234, Statsd.port
    end
    
  end
  
  context "host_ip_addr" do
    
    should "resolve dns" do
      Statsd.host = 'localhost'
      assert_equal '127.0.0.1', Statsd.host_ip_addr
    end
    
  end
  
  private
  
  def fake_rand(v)
    Statsd.stubs(:rand).returns(v)
  end
  
  def expected_send(buf)
    UDPSocket.any_instance.expects(:send).with(buf, 0, Statsd.host_ip_addr, Statsd.port).once
  end
  
  def expect_nothing
    UDPSocket.any_instance.expects(:send).never
  end
  
end