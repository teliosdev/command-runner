describe Command::Runner do

  before :each do
    Command::Runner.backend = Command::Runner::Backends::UnsafeFake.new
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
      ).to eq ["echo", ["some", "\\`bad\\ value\\`"]]
    end

    it "doesn't interpolate interpolation values" do
      expect(
        subject.contents(:interpolation => "{other}", :other => "hi")
      ).to eq ["echo", ["some", "\\{other\\}"]]
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
      ).to eq ["echo", ["some", "`bad value`"]]
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
      allow(Command::Runner::Backends::PosixSpawn).
        to receive(:available?).and_return(false)
      allow(Command::Runner::Backends::Spawn).
        to receive(:available?).and_return(true)
      expect(Command::Runner.best_backend).
        to be_instance_of Command::Runner::Backends::Spawn

      allow(Command::Runner::Backends::PosixSpawn).
        to receive(:available?).and_return(true)
      expect(Command::Runner.best_backend).
        to be_instance_of Command::Runner::Backends::PosixSpawn
    end
  end

  context "when given bad commands" do
    let(:command) { "some-non-existant-command" }
    let(:arguments) { "" }

    before :each do
      subject.backend = Command::Runner::Backends::Backticks.new
    end

    it "should result in no command" do
      expect(subject.pass).to be_no_command
    end

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
      subject.pass(:interpolation => "`uname -a`") do |message|
        expect(message.stdout).to eq "`uname -a`\n"
      end
    end

    it "returns the last value in the block" do
      expect(
        subject.pass(:interpolation => "hi") { |m| m.stdout }
      ).to eq "hi\n"
    end

    it "returns a message" do
      expect(
        subject.pass
      ).to be_a Command::Runner::Message
    end
  end
end
