describe Runner::Messenger do

  before :each do
    Runner::Messenger.path = Runner::Paths::Fake.new
  end

  subject do
    Runner::Messenger.new(command, arguments)
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

  context "selects paths" do
    it "selects the best path" do
      Runner::Paths::PosixSpawn.stub(:available?).and_return(false)
      Runner::Messenger.best_path.should be_instance_of Runner::Paths::Spawn

      Runner::Paths::PosixSpawn.stub(:available?).and_return(true)
      Runner::Messenger.best_path.should be_instance_of Runner::Paths::PosixSpawn
    end
  end
end
