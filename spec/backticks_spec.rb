describe Command::Runner::Backends::Backticks do

  it "is available" do
    Command::Runner::Backends::Backticks.should be_available
  end

  it "returns a message" do
    value = subject.call("echo", ["hello"])
    value.should be_instance_of Command::Runner::Message
    value.should be_executed
  end

  it "gives the correct time" do
    subject.call("sleep", ["0.5"]).time.should be_within(0.1).of(0.5)
  end
end
