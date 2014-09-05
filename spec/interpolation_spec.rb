describe Command::Runner do

  before :each do
    Command::Runner.backend = Command::Runner::Backends::Fake.new
  end

  subject { Command::Runner.new("gcc", "{env.flags} -o {output} {input} -l{lib}") }
  let(:data) do
    { env: { flags: "-g3" },
      output: "test",
      input: "test.c",
      lib: "m" }
  end

  it "interpolates correctly" do
    value = subject.contents(data).last
    expect(value).to eq ["-g3", "-o", "test", "test.c", "-lm"]
  end
end
