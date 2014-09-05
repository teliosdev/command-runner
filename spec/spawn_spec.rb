describe Command::Runner::Backends::Spawn do

  next unless Process.respond_to?(:spawn) && !(RUBY_PLATFORM == "java" && RUBY_VERSION =~ /\A1\.9/)

  it("is safe") { expect(described_class).to_not be_unsafe }

  it "is available" do
    expect(Command::Runner::Backends::Spawn).to be_available
  end

  it "returns a message" do
    value = subject.call("echo", ["hello"])
    expect(value).to be_instance_of Command::Runner::Message
    expect(value).to be_executed
  end

  it "doesn't block" do
    start_time = Time.now
    value = subject.call("sleep", ["0.5"])
    end_time = Time.now

    expect(end_time - start_time).to be_within((1.0/100)).of(0)
    expect(value.time).to be_within((3.0/100)).of(0.5)
  end

  it "doesn't expose arguments to the shell" do
    value = subject.call("echo", ["`uname -a`"])

    expect(value.stdout).to eq "`uname -a`\n"
  end

  it "can be unsafe" do
    value = subject.call("echo", ["`uname -a`"], {}, unsafe: true)

    expect(value.stdout).to_not eq "`uname -a`\n"
  end

  it "can not be available" do
    allow(Command::Runner::Backends::Spawn).to receive(:available?).and_return(false)

    expect {
      Command::Runner::Backends::Spawn.new
    }.to raise_error(Command::Runner::NotAvailableBackendError)
  end

end
