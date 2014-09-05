describe Command::Runner::Backends::Backticks do

  it "is available" do
    expect(Command::Runner::Backends::Backticks).to be_available
  end

  it("is unsafe") { expect(described_class).to be_unsafe }

  it "returns a message" do
    value = subject.call("echo", ["hello"])
    expect(value).to be_instance_of Command::Runner::Message
    expect(value).to be_executed
  end

  it "gives the correct time" do
    expect(subject.call("sleep", ["0.5"]).time).to be_within(0.1).of(0.5)
  end

end
