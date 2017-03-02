require 'chiscore/checkpoints'

describe ChiScore::Checkpoints do
  let(:checkpoint) { ChiScore::Checkpoint.new(1, "The Bottom Lounge") }

  describe ChiScore::Checkpoint do
    it "has an id" do
      expect(checkpoint.id).to eq(1)
    end

    it "has a name" do
      expect(checkpoint.name).to eq("The Bottom Lounge")
    end

    it "has a role" do
      expect(checkpoint.role).to eq("default")
    end

    it "has a list of all teams" do
      route1 = ChiScore::Route.new(1, [checkpoint.id.to_s])
      route2 = ChiScore::Route.new(2, ['3'])

      ChiScore::Routes.save(route1)
      ChiScore::Routes.save(route2)

      team1 = ChiScore::Team.new(:id => 1, :route => route1.id)
      team2 = ChiScore::Team.new(:id => 2, :route => route2.id)

      ChiScore::Teams.save(team1)
      ChiScore::Teams.save(team2)

      expect(checkpoint.all_teams).to eq([team1])
    end
  end

  it "saves a checkpoint" do
    ChiScore::Checkpoints.save(checkpoint)
    expect(ChiScore::Checkpoints.find(checkpoint.id)).to eq(checkpoint)
  end
end
