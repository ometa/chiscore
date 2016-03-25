require 'chiscore/logins'

describe ChiScore::Login do

  let(:checkpoint_login) { ChiScore::Login.new(1, 'username', 'password', 1) }
  let(:admin_login) { ChiScore::Login.new(2, 'username', 'password', 0) }
  before {
    ChiScore::Checkpoints.save(ChiScore::Checkpoint.new(2, "Roots"))
  }

  it "has a login account with a username and password" do
    checkpoint_login.id.should == 'login_1'
    checkpoint_login.username.should == 'username'
    checkpoint_login.password.should_not == 'password'
  end

  it "is authorized if the password matches a login" do
    checkpoint_login.auth?('password').should == true
    checkpoint_login.auth?('derp').should == false
  end

  it "is an admin account if access is 0" do
    admin_login.admin?.should == true
    checkpoint_login.admin?.should == false
  end

  it "has one associated checkpoint if access isn't 0" do
    checkpoint_login.checkpoints.id.should == 1
  end

  it "has all checkpoints if admin" do
    admin_login.checkpoints.count.should > 1
  end

end

describe ChiScore::Logins do
  before(:each) {
    ChiScore::Logins.save(ChiScore::Login.new(2, "roots", "password", 2))
  }

  it "finds a login by its username" do
    ChiScore::Logins.find_by_username("roots").username.should == "roots"
  end

end
