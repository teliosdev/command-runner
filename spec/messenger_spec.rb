describe Command::Runner do

  before :each do
    Command::Runner.backend = Command::Runner::Backends::Fake.new
  end

  subject do
    Command::Runner.new(command, arguments)
  end

  context "when interpolating" do
    let(:command) { "echo" }
    let(:arguments) { "some {interpolation}" }

    it "interpolates correctly" do
      expect(
        subject.contents(:interpolation => "test")
      ).to eq ["echo", ["some", "test"]]
    end

    it "escapes bad values" do
      expect(
        subject.contents(:interpolation => "`bad value`")
      ).to eq ["echo", ["some", "`bad value`"]]
    end

    it "doesn't interpolate interpolation values" do
      expect(
        subject.contents(:interpolation => "{other}", :other => "hi")
      ).to eq ["echo", ["some", "{other}"]]
    end
  end

  context "when interpolating double strings" do
    let(:command) { "echo" }
    let(:arguments) { "some {{interpolation}}" }

    it "interpolates correctly" do
      expect(
        subject.contents(:interpolation => "test")
      ).to eq ["echo", ["some", "test"]]
    end

    it "doesn't escape bad values" do
      expect(
        subject.contents(:interpolation => "`bad value`")
      ).to eq ["echo", ["some", "`bad", "value`"]]
    end
  end

  context "when interpolating misinterpolated strings" do
    let(:command) { "echo" }
    let(:arguments) { "some {{interpolation}" }

    it "doesn't interpolate" do
      expect(
        subject.contents(:interpolation => "test")
      ).to eq ["echo", ["some", "{{interpolation}"]]
    end
  end

  context "when selecting backends" do
    it "selects the best backend" do
      Command::Runner::Backends::PosixSpawn.stub(:available?).and_return(false)
      Command::Runner::Backends::Spawn.stub(:available?).and_return(true)
      Command::Runner.best_backend.should be_instance_of Command::Runner::Backends::Spawn

      Command::Runner::Backends::PosixSpawn.stub(:available?).and_return(true)
      Command::Runner.best_backend.should be_instance_of Command::Runner::Backends::PosixSpawn
    end

    it "takes into account unsafe backends" do
      Command::Runner.best_backend(true).should be_unsafe
    end
  end

  context "when given bad commands" do
    let(:command) { "some-non-existant-command" }
    let(:arguments) { "" }

    before :each do
      subject.backend = Command::Runner::Backends::Backticks.new
    end

    its(:pass) { should be_no_command }

    it "calls the block given" do
      subject.pass do |message|

        expect(message.line).to eq "some-non-existant-command "
      end
    end
  end

  context "when passing commands" do
    let(:command) { "echo" }
    let(:arguments) { "{interpolation}" }

    before :each do
      subject.backend = Command::Runner::Backends::Backticks.new
    end

    it "escapes bad values" do
      subject.pass(interpolation: "`uname -a`") do |message|
        expect(message.stdout).to eq "`uname -a`\n"
      end
    end

    it "returns the last value in the block" do
      expect(
        subject.pass(interpolation: "hi") { |m| m.stdout }
      ).to eq "hi\n"
    end

    it "returns a message" do
      expect(
        subject.pass
      ).to be_a Command::Runner::Message
    end
  end
end
