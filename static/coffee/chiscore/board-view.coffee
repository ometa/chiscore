appendCheckin = (el, checkin) -> el.append checkin.render()

class ChiScore.SubmitView extends Backbone.View
  initialize: (opts) ->  @boardView = opts.boardView

  events:
    "submit form#checkin" : "createCheckin"

  createCheckin: (ev) ->
    ev.preventDefault()
    input = @$el.find('.sign-up-input')
    teamId = input.val()
    input.val("")

    ChiScore.Services.checkInTeam teamId, (resp) =>
      if(resp.success is true)
        @boardView.addCheckin(resp)
      else
        time = ChiScore.util.displayableTime(resp.time)
        alert(
          "That team still has #{time} left at #{resp.checkpoint.name} " +
          "Tell them to stop cheating."
        )


class ChiScore.BoardView extends Backbone.View

  constructor: (options) ->
    this.setElement(options.el || $('ul#checkins'))
    this.useCheckins(options.checkins)
    @submitView = new ChiScore.SubmitView({
      el: $('body'),
      boardView: this
    })

  render: -> _.each @checkinViews, (view) => appendCheckin(this.$el, view)

  reset: -> this.$el.children('li').remove()

  useCheckins: (checkins) ->
    @checkins = checkins
    @checkinViews = @checkins.map (checkin) ->
      new ChiScore.CheckinView(checkin)

  tick: ->
    _.each @checkinViews, (view) =>
      checkin = view.checkin
      checkin.tick()
      view.updateTime()

  addCheckin: (resp) ->
    checkin = new ChiScore.Checkin(resp)
    view = new ChiScore.CheckinView(checkin)

    appendCheckin(this.$el, view)

    @checkins.add(checkin)
    @checkinViews.push(view)

  sync: (checkpointId = null) ->
    fn = null
    if checkpointId?
      fn = _.partial(ChiScore.Services.publicTimes, checkpointId)
    else
      fn = ChiScore.Services.getTimes

    fn (response) =>
      checkins = new ChiScore.CheckinCollection(response)
      this.useCheckins(checkins)
      this.reset()
      this.render()
