require 'chiscore/support/static_collection'
require 'chiscore/teams'

module ChiScore
  class Route
    attr_accessor :id, :checkpoint_ids

    def initialize(id, checkpoint_ids)
      self.id = id
      self.checkpoint_ids = checkpoint_ids.compact
    end

    def teams
      Teams.for_route(self)
    end

    def checkpoints
      checkpoint_ids.map { |id| Checkpoints.find(id) }
    end
  end

  class Routes
    extend Support::StaticCollection
  end
end
