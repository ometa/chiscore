require 'chiscore/teams'


describe ChiScore::Teams do
  let(:team) {
    ChiScore::Team.new(:number => 42, :name => "Dynasty", :route => 5, :id => "forty-two")
  }

  describe ChiScore::Team do
    it "has an id" do
      team.id.should == "forty-two"
    end

    it "has a name" do
      team.name.should == "Dynasty"
    end

    it "has a route" do
      team.route.should == 5
    end

    it "initalizes checkins/checkouts to empty list" do
      team.checkins.should == []
      team.checkouts.should == []
    end

    describe "#<=>" do
      let(:team1) {
        ChiScore::Team.new(:number => 1, :name => "team1", :route => 5, :id => "life")
      }
      let(:team2) {
        ChiScore::Team.new(:number => 2, :name => "team2", :route => 5, :id => "the-universe")
      }

      it "team with more checkouts comes first" do
        team2.checkouts << :a << :b
        team1.checkouts << :a
        expect([team1, team2].sort.first).to eq(team2)
        expect([team2, team1].sort.first).to eq(team2)
      end

      it "team with more checkins when checkouts are equal comes first" do
        team2.checkouts << :a
        team1.checkouts << :a
        team2.checkins << :a
        expect([team1, team2].sort.first).to eq(team2)
        expect([team2, team1].sort.first).to eq(team2)
      end
    end

    it "gets teams with a given route" do
      route = double(:id => 5)
      ChiScore::Teams.for_route(route).should == [team]
    end
  end

  it "stores a team" do
    ChiScore::Teams.save(team)
    ChiScore::Teams.find(team.id).should == team
  end
end
