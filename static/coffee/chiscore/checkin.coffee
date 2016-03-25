class ChiScore.Checkin extends Backbone.Model
  defaults:
    team: { name : '' },
    time: (25 * 60)

  tick: ->
    time = this.get('time')
    this.set('time', time - 1) if time > 0
