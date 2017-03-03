ChiScore = window.ChiScore = {}
ChiScore.Models = {}
ChiScore.Collections = {}

ChiScore.util =
  displayableTime : (stringTime) ->
    time = parseInt(stringTime)
    return "00:00" if time < 1

    minutes = Math.floor(time / 60)
    seconds = time % 60

    seconds = "0" + seconds if seconds < 10
    minutes = "0" + minutes if minutes < 10
    "#{minutes}:#{seconds}"

  canEarlyCheckout: (checkin) ->
    minutes = Math.floor(time / 60)
    return minutes <= 4


ChiScore.main = ->
  return unless $('ul#checkins').length > 0

  if $('ul#checkins').hasClass('checkpoint-checkins')
    ChiScore.checkinMain()
    return

  ChiScore.Services.getTimes (resp) ->
    checkins  = new ChiScore.CheckinCollection(resp)
    boardView = new ChiScore.BoardView({checkins: checkins})

    boardView.render()

    ticker = ->
      setTimeout((->
        boardView.tick()
        ticker()
      ), 1000)

    syncTicker = ->
      setTimeout((->
        boardView.sync()
        syncTicker()
      ), 4000)

    ticker()
    syncTicker()

ChiScore.checkinMain = ->
  checkpointId = $("ul#checkins").attr('data-checkpoint-id')
  ChiScore.isPublic = true

  ChiScore.Services.publicTimes checkpointId, (resp) ->
    checkins  = new ChiScore.CheckinCollection(resp)
    boardView = new ChiScore.BoardView({checkins: checkins})

    boardView.render()

    ticker = ->
      setTimeout((->
        boardView.tick()
        ticker()
      ), 1000)

    syncTicker = ->
      setTimeout((->
        boardView.sync(checkpointId)
        syncTicker()
      ), 10000)

    ticker()
    syncTicker()
