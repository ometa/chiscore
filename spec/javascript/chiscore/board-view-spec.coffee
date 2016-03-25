describe "ChiScore.BoardView", ->
  el = null

  beforeEach -> el = affix("ul#checkins")

  it "takes a collection of checkins", ->
    checkins = new ChiScore.CheckinCollection()

    view = new ChiScore.BoardView({ el: el, checkins: checkins })
    expect(view.checkins).toEqual(checkins)

  it "renders the list of checkins", ->
    checkin = new ChiScore.Checkin({ team : { name : "dynasty" }})
    checkins = new ChiScore.CheckinCollection([checkin])

    view = new ChiScore.BoardView({ el: el, checkins: checkins })

    view.render()

    expect(el.children('li').length).toEqual(1)
    expect(el.find('li:first span.team-name').text()).toEqual("dynasty")

  it "resets the board", ->
    checkin = new ChiScore.Checkin({ team : { name : "dynasty" }})
    checkins = new ChiScore.CheckinCollection([checkin])

    view = new ChiScore.BoardView({ el: el, checkins: checkins })
    view.render()

    view.reset()
    expect(el.children('li').length).toEqual(0)
