require 'chiscore/routes'

describe ChiScore::Routes do
  let(:route) {
    ChiScore::Route.new(1, [1, 2, 3])
  }

  describe ChiScore::Route do
    it "has a route ID" do
      expect(route.id).to eq(1)
    end

    it "has a list of checkpoint IDs" do
      expect(route.checkpoint_ids).to eq([1, 2, 3])
    end

    it "truncates the checkpoint IDs if they're nil" do
      expect(ChiScore::Route.new(1, [1, 2, nil]).checkpoint_ids).to eq([1,2])
    end

    it "has a list of checkpoints" do
      checkpoint1, checkpoint2, checkpoint3 = [1, 2, 3].map { |num| ChiScore::Checkpoint.new(num, num.to_s)}
      allow(ChiScore::Checkpoints).to receive(:find).with(1) { checkpoint1 }
      allow(ChiScore::Checkpoints).to receive(:find).with(2) { checkpoint2 }
      allow(ChiScore::Checkpoints).to receive(:find).with(3) { checkpoint3 }
      expect(route.checkpoints).to eq([checkpoint1, checkpoint2, checkpoint3])
    end

    it "has teams" do
      team = double
      allow(ChiScore::Teams).to receive(:for_route).with(route) { [ team ] }
      expect(route.teams).to eq([team])
    end
  end

  it "saves a route" do
    ChiScore::Routes.save(route)
    expect(ChiScore::Routes.find(route.id)).to eq(route)
  end
end
