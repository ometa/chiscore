require 'chiscore/support/static_collection'
require 'digest/sha1'
require 'base64'

module ChiScore
  class Checkpoint
    attr_accessor :id, :name, :role

    def initialize(id, name, role='default')
      self.id, self.name, self.role = id, name, role
    end

    def all_teams
      Routes.all.select do |route|
        route.checkpoint_ids.include?(self.id.to_s)
      end.map(&:teams).flatten.uniq
    end
  end

  class Checkpoints
    extend Support::StaticCollection
  end
end
