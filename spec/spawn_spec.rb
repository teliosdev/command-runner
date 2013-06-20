describe Runner::Paths::Spawn do
  it "is available" do
    Runner::Paths::Spawn.should be_available
  end

  it "returns a message" do
    value = subject.call("echo", "hello")
    value.should be_instance_of Runner::Message
    value.should be_executed
  end

  it "doesn't block" do
    start_time = Time.now
    value = subject.call("sleep", "0.5")
    end_time = Time.now

    (end_time - start_time).should be_within((1.0/100)).of(0)
    value.time.should be_within((1.0/100)).of(0.5)
  end
end
