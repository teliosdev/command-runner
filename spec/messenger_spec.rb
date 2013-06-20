describe Command::Runner do

  before :each do
    Command::Runner.backend = Command::Runner::Backends::Fake.new
  end

  subject do
    Command::Runner.new(command, arguments)
  end

  context "interpolating strings" do
    let(:command) { "echo" }
    let(:arguments) { "some {interpolation}" }

    it "interpolates correctly" do
      subject.contents(interpolation: "test").should == ["echo", "some test"]
    end

    it "escapes bad values" do
      subject.contents(interpolation: "`bad value`").should == ["echo", "some \\`bad\\ value\\`"]
    end

    it "doesn't interpolate interpolation values" do
      subject.contents(interpolation: "{other}", other: "hi").should == ["echo", "some \\{other\\}"]
    end
  end

  context "double interpolated strings" do
    let(:command) { "echo" }
    let(:arguments) { "some {{interpolation}}" }

    it "interpolates correctly" do
      subject.contents(interpolation: "test").should == ["echo", "some test"]
    end

    it "doesn't escape bad values" do
      subject.contents(interpolation: "`bad value`").should == ["echo", "some `bad value`"]
    end
  end

  context "misinterpolated strings" do
    let(:command) { "echo" }
    let(:arguments) { "some {{interpolation}" }

    it "doesn't interpolate" do
      subject.contents(interpolation: "test").should == ["echo", "some {{interpolation}"]
    end
  end

  context "selects backends" do
    it "selects the best backend" do
      Command::Runner::Backends::PosixSpawn.stub(:available?).and_return(false)
      Command::Runner.best_backend.should be_instance_of Command::Runner::Backends::Spawn

      Command::Runner::Backends::PosixSpawn.stub(:available?).and_return(true)
      Command::Runner.best_backend.should be_instance_of Command::Runner::Backends::PosixSpawn
    end
  end
end
