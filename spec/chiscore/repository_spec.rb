require 'chiscore/repository'
require 'chiscore/repository/noop_strategy'

describe ChiScore::Repository do
  let(:strategy) { ChiScore::NoopRepositoryStrategy }

  it "sets/gets a strategy" do
    ChiScore::Repository.set_strategy(strategy)
    ChiScore::Repository.strategy.should == strategy
  end

  [
    :check_in!,
    :active_for,
    :checkins_for,
    :checkouts_for,
    :time_for,
    :check_out!,
    :save_race_start,
    :fetch_race_start
  ].each do |method_name|
    it "delegates #{method_name} to strategy" do
      ChiScore::Repository.set_strategy(strategy)
      strategy.should_receive(method_name)

      ChiScore::Repository.send(method_name)
    end
  end

  it "raises a strategy not set error if there is no strategy" do
    ChiScore::Repository.set_strategy(nil)

    expect {
      ChiScore::Repository.checkins_for
    }.to raise_error ChiScore::Repository::StrategyNotSet
  end
end
