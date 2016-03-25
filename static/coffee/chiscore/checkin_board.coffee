class ChiScore.CheckinBoardView
  constructor : (@parentElement = $("ul#checkins")) ->

  init : (board) ->
    this.board = board
    this.reset()
    this.appendCheckin(checkin) for checkin in @board.checkins
    this.bindCheckout()
    this.bindCheckin()

  sync: (board) ->
    this.board = board
    this.reset()
    this.appendCheckin(checkin) for checkin in @board.checkins
    this.bindCheckout()

  render : (checkin) -> this._render({checkin : checkin})
  _render : (obj) -> window.EJS.checkin(obj)

  reset : -> @parentElement.children('li').remove();

  appendCheckin : (checkin) -> @parentElement.append(this.render(checkin))

  update : (checkin) ->
    spanner = @parentElement.find("li[data-team-id='#{checkin.team.id}'] span.team-time")
    spanner.html(ChiScore.util.displayableTime(checkin.time))

    if checkin.time <= 0
      spanner.addClass('out')
      spanner.removeClass('warning')
    else if checkin.time < 120
      spanner.addClass('warning')

  bindCheckout : ->
    $("span.smiley").on "click", (e) ->
      if confirm("Are you sure you want to flag this team as a smiley team?")
        teamId = $(this).parent('li').attr('data-team-id')
        ChiScore.Services.flagTeam(teamId)

    $("div.check-out-link").on "click", (e) ->
      e.preventDefault()
      teamId = $(this).parent('li').attr('data-team-id')
      ChiScore.Services.checkOutTeam teamId, (response) ->
        if response.success is true
          $("li[data-team-id=#{response.team.id}]").slideUp 100, -> $(this).remove()
        else
          alert("You can't check out that team yet!")

  bindCheckin : ->
    $("form#checkin").bind "submit", (e) =>
      e.preventDefault()
      @board.createCheckin($(".sign-up-input").val())
      $(".sign-up-input").val("")

class ChiScore.CheckinBoard
  constructor : ->
    @checkins = []
    @view = new ChiScore.CheckinBoardView()

  init : -> this.sync => @view.init(this)

  reset : -> this.sync => @view.sync(this)

  sync : (fn) ->
    ChiScore.Services.getTimes (response) =>
      @checkins = response
      fn() if fn

  tick : -> for checkin in @checkins
    if checkin.time > 0
      checkin.time -= 1
      @view.update(checkin)

  createCheckin : (teamId) ->
    ChiScore.Services.checkInTeam teamId, (checkin) =>
      if(checkin.success is true)
        @checkins.push(checkin)
        @view.appendCheckin(checkin)
      else
        time = ChiScore.util.displayableTime(checkin.time)
        alert("That team has #{time} left at #{checkin.checkpoint.name}. Tell them to stop cheating")
