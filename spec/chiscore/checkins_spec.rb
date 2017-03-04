require 'rack/test'
require 'chiscore/checkins'
require 'chiscore/checkpoints'

describe ChiScore::Checkins do
  let(:team) { ChiScore::Team.new(:id => "team-id", :name => "Dynasty") }
  let(:checkpoint) { ChiScore::Checkpoint.new(1000, "Nick's") }
  let(:endpoint) { ChiScore::Checkpoint.new(1001, "Nancy's", "endpoint") }
  let(:repo) { ChiScore::Repository }

  it "saves the finish-line's check-in and check-out at the same time" do
    allow(repo).to receive(:lock).with("team-id") { -1 }
    expect(repo).to receive(:check_in!).with(1001, "team-id")
    expect(repo).to receive(:check_out!).with(1001, "team-id")

    ChiScore::Checkins.checkin(endpoint, team)
  end

  it "saves a checkin" do
    allow(repo).to receive(:lock).with("team-id") { -1 }
    expect(repo).to receive(:check_in!).with(1000, "team-id")
    expect(repo).not_to receive(:check_out!)

    ChiScore::Checkins.checkin(checkpoint, team)
  end

  it "raises a LockedCheckinAttempt exception if the team has a TTL" do
    allow(repo).to receive(:lock).with("team-id") { 100 }

    expect {
      ChiScore::Checkins.checkin(checkpoint, team)
    }.to raise_error ChiScore::Checkins::LockedCheckinAttempt
  end

  it "finds all current checkins for a given checkpoint" do
    expect(repo).to receive(:active_for).with(1000)

    ChiScore::Checkins.active(checkpoint)
  end

  it "returns a countdown in seconds for all current checkins" do
    allow(repo).to receive(:active_for) { ["teamid1", "teamid2"] }
    allow(ChiScore::Teams).to receive(:find).with("teamid1") { double(:name => "team-one") }
    allow(ChiScore::Teams).to receive(:find).with("teamid2") { double(:name => "team-two") }
    allow(repo).to receive(:time_for).with(1000, "teamid1") { 100 }
    allow(repo).to receive(:time_for).with(1000, "teamid2") { 200 }


    result = expect(ChiScore::Checkins.times_for(checkpoint)).to match_array([
      { :team => { :name => "team-one", :id => "teamid1" }, :time => 100 },
      { :team => { :name => "team-two", :id => "teamid2" }, :time => 200 }
    ])
  end

  it "checks out a team if their time left is less than a minute" do
    allow(repo).to receive(:lock).with("team-id") { 59 }
    expect(repo).to receive(:check_out!).with(1000, "team-id")
    ChiScore::Checkins.checkout(checkpoint, team, false)
  end

  it "raises an early checkout error if team time left is a minute or greater" do
    allow(repo).to receive(:lock).with("team-id") { 60 }
    expect {
      ChiScore::Checkins.checkout(checkpoint, team, false)
    }.to raise_error ChiScore::Checkins::EarlyCheckout
  end

  it "does not raise early checkout error if team time left is a minute or greater and admin" do
    repo.set_strategy(ChiScore::NoopRepositoryStrategy)
    allow(repo).to receive(:lock).with("team-id") { 60 }

    expect {
      ChiScore::Checkins.checkout(checkpoint, team, true)
    }.not_to raise_error
  end

  it "delegates destruction to the repository if admin" do
    allow(repo).to receive(:destroy_checkin!) { "destroyed" }
    allow(repo).to receive(:lock) { 100 }
    expect(ChiScore::Checkins.destroy_checkin(checkpoint, team, true)).to eq("destroyed")
  end

  it "returns an Illegal Destroy error if not admin" do
    allow(repo).to receive(:lock).with("team-id") { 100 }

    expect{
      ChiScore::Checkins.destroy_checkin(checkpoint, team, false)
    }.to raise_error ChiScore::Checkins::IllegalDestroy
  end

  it "does not raise error if there are fewer than 4 minutes expired from check-in time" do
    allow(repo).to receive(:lock).with("team-id") { 1301 }
    allow(repo).to receive(:destroy_checkin!) { "destroyed" }

    expect(
      ChiScore::Checkins.destroy_checkin(checkpoint, team, false)
    ).to eq "destroyed"
  end

  it "gets the remaining teams" do
    out_time, in_time = Time.now, Time.now - 25 * 60

    team1 = ChiScore::Team.new(:id => 1)
    team2 = ChiScore::Team.new(:id => 2)
    team3 = ChiScore::Team.new(:id => 3)

    ChiScore::Teams.save(team1)
    ChiScore::Teams.save(team2)
    ChiScore::Teams.save(team3)

    allow(checkpoint).to receive(:all_teams) { [team1, team2, team3] }

    allow(repo).to receive(:checkins_for) do
      { team1.id => in_time, team2.id => in_time }
    end

    expect(ChiScore::Checkins.remaining_teams(checkpoint)).to eq([team3])
  end

  it "gets all checkin / checkout times for a checkpoint" do
    out_time, in_time = Time.now, Time.now - 25 * 60

    allow(ChiScore::Teams).to receive(:find).with("teamid1") { double(:name => "team-one") }
    allow(ChiScore::Teams).to receive(:find).with("teamid2") { double(:name => "team-two") }
    allow(ChiScore::Teams).to receive(:find).with("teamid3") { double(:name => "team-three") }

    allow(repo).to receive(:checkins_for) do
      {"teamid1" => in_time, "teamid2" => in_time, "teamid3" => in_time}
    end

    allow(repo).to receive(:checkouts_for) {{ "teamid1" => out_time, "teamid2" => out_time }}

    expect(ChiScore::Checkins.all_for(checkpoint)).to eq([
      { :team => { :name => "team-one", :id => "teamid1"}, :times => [in_time, out_time]},
      { :team => { :name => "team-two", :id => "teamid2"}, :times => [in_time, out_time]},
      { :team => { :name => "team-three", :id => "teamid3"}, :times => [in_time, nil]}
    ])
  end
end
