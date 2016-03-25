module ChiScore
  module Support
    module StaticCollection
      def save(element)
        if element.is_a?(Array)
          element.each{ |element| self._collection.store(element.id, element) }
        else
          self._collection.store(element.id, element)
        end
      end

      def find(id)
        begin
          self._collection.fetch(id)
        rescue KeyError => e
          self._collection.fetch(id.to_i)
        end
      end

      def all
        _collection.values
      end

      def _collection
        @_collection ||= Hash.new
      end
    end
  end
end
