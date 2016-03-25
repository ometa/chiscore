class ChiScore.CheckinCollection extends Backbone.Collection
  model: ChiScore.Checkin
  comparator: (checkin) -> checkin.get('time')
