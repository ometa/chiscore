describe 'ChiScore.ActiveBoard', ->
  checkpoint = null

  times = [{ team : { id : "1", name : "Dynasty" }, time : 113 }]

  beforeEach -> checkpoint = new ChiScore.ActiveBoard(1)

  it "syncs checkins from Services.getActiveTeams", ->
    spyOn(ChiScore.Services, "getActiveTeams").and.callFake (id, fn) -> fn(times)
    checkpoint.sync()
    expect(checkpoint.checkins).toEqual(times)

  it "assigns each checkpoint to a list", ->
    view = checkpoint.view
    expect(view.parentElement.selector).toEqual("ul#checkpoint1")

  it "appends all checkins to corresponding list", ->
    view = checkpoint.view
    spyOn(view.parentElement, "append")
    spyOn(view, "render").and.returnValue("rendered")
    view.appendCheckin("checkin", "checkpoint")
    expect(view.parentElement.append).toHaveBeenCalledWith("rendered")

  it "requires both checkpoint-id and team-id for checkout", ->
    spyOn(ChiScore.Services, "earlyCheckOut")
    setFixtures("<ul id='checkpoint1'><li data-team-id='1' data-checkpoint-id='2'>thing<a class='check-out-link' id='test'>x</a></li></ul>")
    view = checkpoint.view
    view.bindCheckout()
    $("#test").click()
    expect(ChiScore.Services.earlyCheckOut).not.toHaveBeenCalledWith(['1'])

  it "requires both checkpoint-id and team-id for checkout", ->
    view = checkpoint.view
    spyOn(view, "getConfirmation")
    setFixtures("<ul id='checkpoint1'><li data-team-id='1' data-checkpoint-id='2'>thing<a class='destroy-checkin' id='test'>x</a></li></ul>")
    view.bindDestroyCheckin()
    $("#test").click()
    expect(view.getConfirmation).toHaveBeenCalled()
