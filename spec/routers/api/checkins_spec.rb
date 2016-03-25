require 'rack/test'
require 'spec_helper'
require 'routers/api/checkins'
require 'chiscore/auth'
require 'chiscore/teams'
require 'chiscore/checkpoints'
require 'chiscore/checkins'
require 'chiscore/repository/noop_strategy'
require 'routers/auth'
require 'routers/router'

describe Routers::Api::Checkins do
  include Rack::Test::Methods

  let(:app) { Routers::Api::Checkins }
  let(:checkpoint) { ChiScore::Checkpoint.new(1000, "Barname") }
  let(:team) { ChiScore::Team.new(:id => "team-id", :name => "Dynasty") }

  before {
    ChiScore::Auth.stub(:login_auth) { true }
    ChiScore::Checkpoints.stub(:find) { checkpoint }
    ChiScore::Teams.stub(:find) { team }
    ChiScore::Auth.stub(:admin_key) { "the-admin-key" }
  }

  context "#set_checkpoint" do
    before { ChiScore::Checkins.stub(:times_for) }
    it "checks the session for the checkpoint when checkpoint" do
      ChiScore::Checkpoints.should_receive(:find).with("9999")

      get "/",
        {"checkpoint" => "8888"},
        'rack.session' => {'checkpoint-id' => "9999" }
    end

    it "checks the params for the checkpoint when admin" do
      app.any_instance.stub(:admin?) { true }

      ChiScore::Checkpoints.should_receive(:find).with("8888")

      get "/",
        {"checkpoint" => "8888"},
        'rack.session' => {'checkpoint-id' => "9999" }
    end
  end

  it "gets the checkins for checkpoint" do
    times = { 'team-one' => 45, 'team-two' => 33 }
    ChiScore::Checkins.stub(:times_for).with(checkpoint) { times }

    get "/"

    last_response.status.should == 200
    last_response.body.should == times.to_json
  end

  it "posts the checkins for checkpoint" do
    times = { 'team-one' => 45, 'team-two' => 33 }
    ChiScore::Checkins.stub(:times_for).with(checkpoint) { times }

    post "/",
         {"checkpoint" => "1000"}

    last_response.status.should == 200
    last_response.body.should == times.to_json
  end

  it "creates a checkin for checkpoint" do
    ChiScore::Checkins.should_receive(:checkin).with(checkpoint, team)
    post "/checkin", 'team_id' => "team-id"
    last_response.body.should == {
      :success => true,
      :team => { :id => "team-id", :name => "Dynasty" },
      :time => 1500
    }.to_json
  end

  it "creates a checkin/checkout for the finish line" do
    finish_line_checkpoint = ChiScore::Checkpoint.new(1337, "Finish Line", "endpoint")
    ChiScore::Checkpoints.stub(:find) { finish_line_checkpoint }
    ChiScore::Checkins.should_receive(:checkin).with(finish_line_checkpoint, team)

    post "/checkin", 'team_id' => "team-id"
  end

  it "returns an error and gives the location if the team is locked" do
    ChiScore::Checkins.stub(:checkin).and_raise(ChiScore::Checkins::LockedCheckinAttempt)
    ChiScore::Checkins.stub(:active).and_return(["team-id"])
    ChiScore::Repository.stub(:time_for).and_return("time-remaining")

    post "/checkin", 'team_id' => "team-id"

    last_response.body.should == {
      :success => false,
      :checkpoint => {:id => "1", :name => "The Bottom Lounge"},
      :time => "time-remaining"
    }.to_json
  end

  it "creates a checkout for checkpoint" do
    ChiScore::Checkins.should_receive(:checkout).with(checkpoint, team, false)
    post "/checkout", 'team_id' => "team-id"
    last_response.body.should == {
      :success => true,
      :team => { :id => "team-id", :name => "Dynasty" }
    }.to_json
  end

  it "returns an error if the checkout is too early" do
    ChiScore::Checkins.stub(:checkout).and_raise(ChiScore::Checkins::EarlyCheckout)
    post "/checkout", 'team_id' => "team-id"
    last_response.body.should == { :success => false }.to_json
  end

  it "does not return an error if the checkout is too early and current user is admin" do
    ChiScore::Checkins.should_receive(:checkout).with(checkpoint, team, true)

    app.any_instance.stub(:admin?) { true }

    post "/checkout", {'team_id' => "team-id"}

    last_response.body.should == {
      :success => true,
      :team => { :id => "team-id", :name => "Dynasty" }
    }.to_json
  end

  it "destroys a checkin if admin" do
    app.any_instance.stub(:admin?) { true }
    post "/destroy", { 'team_id' => "team-id", 'checkpoint' => "1000" }

    last_response.body.should == {
      :destroyed => true,
      :team => { :id => "team-id", :name => "Dynasty" }
    }.to_json
  end

  it "does not destory a checkin if not admin" do
    post "/destroy", { 'team_id' => "team-id" }

    last_response.body.should == { :destroyed => false }.to_json
  end

  it "gets all the checkins/checkouts for checkpoint" do

    in_time, out_time = Time.now - 25 * 60, Time.now

    checkins = {
      'team-one' => [in_time, out_time],
      'team-two' => [in_time, out_time]
    }

    Routers::Router.stub(:require_auth! => checkins)

    ChiScore::Checkins.should_receive(:all_for).with(checkpoint) { checkins }

    get "/all"

    last_response.body.should == checkins.to_json
  end
end
