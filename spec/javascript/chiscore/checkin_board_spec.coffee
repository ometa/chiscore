describe 'ChiScore.CheckinBoard', ->
  board = null

  times = [{
      team : { id : "1", name : "Dynasty" },
      time : 113
    }]

  beforeEach -> board = new ChiScore.CheckinBoard()

  it 'has a list of checkins', -> expect(board.checkins).toEqual([])

  it 'syncs checkins from Services module', ->
    spyOn(ChiScore.Services, "getTimes").and.callFake (fn) -> fn(times)

    board.sync()
    expect(board.checkins).toEqual(times)

  it '"ticks" and lowers each time by one', ->
    originalTime = times[0].time
    board.checkins = times
    board.tick()
    expect(times[0].time).toEqual(originalTime - 1)

  it "doesn't lower times that are 0", ->
    times[0].time = 0
    board.checkins = times
    board.tick()
    expect(board.checkins[0].time).toEqual(0)

  it "'init' syncs and renders the check-ins", ->
    spyOn(ChiScore.CheckinBoardView.prototype, "init")
    spyOn(ChiScore.Services, "getTimes").and.callFake (fn) -> fn(times)

    board.init()

    expect(ChiScore.CheckinBoardView.prototype.init).toHaveBeenCalled()

  it "adds a new checkin to the list of checkins", ->
    checkin = { success : true, team : { id : 1, name : "test" }, time : 1500 }
    spyOn(board.view, "appendCheckin")
    spyOn(ChiScore.Services, "checkInTeam").and.callFake (teamId, fn) -> fn(checkin)

    board.createCheckin(1)

    expect(board.checkins).toEqual([checkin])
    expect(board.view.appendCheckin).toHaveBeenCalled()

describe 'ChiScore.CheckinBoardView', ->
  view = new ChiScore.CheckinBoardView()
  board = new ChiScore.CheckinBoard()

  beforeEach -> view.board = board

  it "adds to the parent element", ->
    spyOn(EJS, "checkin").and.returnValue("rendered")
    spyOn(view.parentElement, "append")
    view.appendCheckin()
    expect(view.parentElement.append).toHaveBeenCalledWith("rendered")

  it "listens to a submit on the check-in form", ->
    setFixtures('<form id="checkin"></form>')
    view.init(board)
    expect($('form#checkin')).toHandle('submit')

  it "listens to a submit on a team's check-out form", ->
    setFixtures('<ul id="checkins"><li data-team-id="1337"><div class="check-out-link" href="#">x</a></li></ul>')
    view.init(board)
    expect($('div.check-out-link')).toHandle('click')

  describe "warning/out classes", ->
    checkin = { team : { name : "Dynasty", id : 1337 }, time : 20 }

    beforeEach ->
      setFixtures('<ul id="checkins"><li data-team-id="1337"><span class="team-time">time</span></li></ul>')
      view = new ChiScore.CheckinBoardView()
      view.appendCheckin(checkin)

    it "adds a warning class if the checkout time is under 2 minutes", ->
      view.update(checkin)

      element = $('ul#checkins li[data-team-id="1337"] span.team-time')
      expect(element).toHaveClass('warning')

    it "adds an 'out' class if the checkout time is 0", ->
      checkin.time = 0

      view.update(checkin)

      element = $('ul#checkins li[data-team-id="1337"] span.team-time')
      expect(element).toHaveClass('out')
