class ChiScore.ActiveBoardView
  constructor : (@parentElement) ->
  init : (checkpoint) ->
    this.appendCheckin(checkin, checkpoint) for checkin in checkpoint.checkins
    this.bindCheckout()
    this.bindDestroyCheckin()

  render : (checkin, checkpoint) -> this._render({checkin : checkin, checkpoint : checkpoint})
  _render : (obj) -> window.EJS.checkout(obj)

  appendCheckin : (checkin, checkpoint) ->
    @parentElement.append(this.render(checkin, checkpoint))

  bindCheckout : ->
    $("a.check-out-link").unbind()

    $("a.check-out-link").on "click", (e) ->
      e.preventDefault()
      teamId       = $(this).parent('li').attr('data-team-id')
      checkpointId = $(this).parent('li').attr('data-checkpoint-id')

      ChiScore.Services.earlyCheckOut checkpointId, teamId, (response) ->
        if response.success is true
          $("li[data-team-id=#{response.team.id}]").slideUp 100, -> $(this).remove()

  bindDestroyCheckin : ->
    _this = this
    $("a.destroy-checkin").unbind()

    $("a.destroy-checkin").on "click", (e) ->
      e.preventDefault()
      teamId       = $(this).parent('li').attr('data-team-id')
      checkpointId = $(this).parent('li').attr('data-checkpoint-id')

      if _this.getConfirmation() is true
        ChiScore.Services.deleteCheckin checkpointId, teamId, (response) =>
          if response.destroyed is true
            $("li[data-team-id=#{response.team.id}]").slideUp 100, -> $(this).remove()

  getConfirmation : ->
    confirm("Are you sure you want to delete this checkin? It could have some very serious consequences for the team")

class ChiScore.ActiveBoard
  constructor : (@checkpointId) ->
    checkpointElement = $("ul#checkpoint#{@checkpointId}")
    @checkins = []
    @view = new ChiScore.ActiveBoardView(checkpointElement)

  init : -> this.sync => @view.init(this)

  sync : (fn) ->
    ChiScore.Services.getActiveTeams @checkpointId, (response) =>
      @checkins = response
      fn() if fn
