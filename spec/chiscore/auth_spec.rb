require 'chiscore/auth'

describe ChiScore::Auth do
  let(:checkpoint) {
    ChiScore::Checkpoint.new(1, "Bottom Lounge")
  }

  before {
    ChiScore::Logins.save(ChiScore::Login.new(1, "bottomlounge", "secretpass", 1))
    ChiScore::Checkpoints.save(checkpoint)
  }

  it "is true if the checkpoint exists and has the correct password" do
    expect(ChiScore::Auth.login_auth("bottomlounge", "secretpass")).to equal(true)
  end

  it "is false if the checkpoint doesn't exist" do
    expect(ChiScore::Auth.login_auth("non-existants!!", "12345")).to be_falsey
  end

  it "is false if the password isn't correct" do
    expect(ChiScore::Auth.login_auth("bottomlounge", "12345")).to be(false)
  end

  it "returns the secret key" do
    expect(File).to receive(:read).with("config/secret_key") { "the-key" }
    expect(ChiScore::Auth.secret_key).to eq("the-key")
  end

  it "reads an admin key from the file system" do
    expect(File).to receive(:read).with("config/admin_key") { "the-key" }
    expect(ChiScore::Auth.admin_key).to eq("the-key")
  end
end
