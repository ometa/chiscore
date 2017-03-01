require 'chiscore/logins'

describe ChiScore::Login do

  let(:checkpoint_login) { ChiScore::Login.new(1, 'username', 'password', 1) }
  let(:admin_login) { ChiScore::Login.new(2, 'username', 'password', 0) }
  before {
    ChiScore::Checkpoints.save(ChiScore::Checkpoint.new(2, "Roots"))
  }

  it "has a login account with a username and password" do
    expect(checkpoint_login.id).to eq('login_1')
    expect(checkpoint_login.username).to eq('username')
    expect(checkpoint_login.password).not_to eq('password')
  end

  it "is authorized if the password matches a login" do
    expect(checkpoint_login.auth?('password')).to eq(true)
    expect(checkpoint_login.auth?('derp')).to eq(false)
  end

  it "is an admin account if access is 0" do
    expect(admin_login.admin?).to eq(true)
    expect(checkpoint_login.admin?).to eq(false)
  end

  it "has one associated checkpoint if access isn't 0" do
    expect(checkpoint_login.checkpoints.id).to eq(1)
  end

  it "has all checkpoints if admin" do
    expect(admin_login.checkpoints.count).to be > 1
  end

end

describe ChiScore::Logins do
  before(:each) {
    ChiScore::Logins.save(ChiScore::Login.new(2, "roots", "password", 2))
  }

  it "finds a login by its username" do
    expect(ChiScore::Logins.find_by_username("roots").username).to eq("roots")
  end

end
