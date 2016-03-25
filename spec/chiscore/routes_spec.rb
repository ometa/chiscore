require 'chiscore/routes'

describe ChiScore::Routes do
  let(:route) {
    ChiScore::Route.new(1, [1, 2, 3])
  }

  describe ChiScore::Route do
    it "has a route ID" do
      route.id.should == 1
    end

    it "has a list of checkpoint IDs" do
      route.checkpoint_ids.should == [1, 2, 3]
    end

    it "truncates the checkpoint IDs if they're nil" do
      ChiScore::Route.new(1, [1, 2, nil]).checkpoint_ids.should == [1,2]
    end

    it "has a list of checkpoints" do
      checkpoint1, checkpoint2, checkpoint3 = [1, 2, 3].map { |num| ChiScore::Checkpoint.new(num, num.to_s)}
      ChiScore::Checkpoints.stub(:find).with(1) { checkpoint1 }
      ChiScore::Checkpoints.stub(:find).with(2) { checkpoint2 }
      ChiScore::Checkpoints.stub(:find).with(3) { checkpoint3 }
      route.checkpoints.should == [checkpoint1, checkpoint2, checkpoint3]
    end

    it "has teams" do
      team = double
      ChiScore::Teams.stub(:for_route).with(route) { [ team ] }
      route.teams.should == [team]
    end
  end

  it "saves a route" do
    ChiScore::Routes.save(route)
    ChiScore::Routes.find(route.id).should == route
  end
end
