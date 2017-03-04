describe 'ChiScore.CheckinView', ->
  [checkin, view] = [null, null]

  beforeEach ->
    checkin = new ChiScore.Checkin({ time: 119, team : {
      id: 'team-id',
      name: 'dynasty'
    }})

    view = new ChiScore.CheckinView(checkin)

    view.render()

  it 'takes a checkin', ->
    expect(view.checkin).toEqual(checkin)

  it 'formats time', ->
    expect(view.getTime()).toEqual('01:59')

  it 'uses a "warning" class if time < 2:00', ->
    view.checkin.set('time', 60)
    expect(view.timeClass()).toEqual('warning')

  it 'uses an "out" class if time is 0:00', ->
    view.checkin.set('time', 0)
    expect(view.timeClass()).toEqual('out')

  it 'uses no class if time is > 2:00', ->
    view.checkin.set('time', 121)
    expect(view.timeClass()).toBeUndefined()

  it 'renders a template', ->
    rendered = $(view._render())
    expect(rendered.find('.team-name').text()).toEqual("dynasty")

  it 'updates the time span when checkin time changes', ->
    view.render()

    checkin.set('time', 118)

    expect(view.$el.find('.team-time').text()).toEqual('01:58')
    expect(view.$el.find('.team-time')).toHaveClass('warning')

  it 'deletes a team check-in if remaining time is above 21:00', ->
    view.render()

    spyOn(window, "confirm").and.returnValue(true)

    removeTeam = spyOn($.fn, "slideUp").and.callFake (time, fn) ->
      expect(time).toEqual(100)
      fn()

    checkin.set('time', 1301)

    destroySpy = spyOn(ChiScore.Services, "deleteCheckin").and.callFake (cId, id, fn) ->
      fn({ destroyed: true })

    view.$el.find('.check-out-link').trigger('click')

    expect(destroySpy).toHaveBeenCalledWith(null, 'team-id', jasmine.any(Function))
    expect(removeTeam).toHaveBeenCalled()

  it 'checks out a team', ->
    view.render()

    removeTeam = spyOn($.fn, "slideUp").and.callFake (time, fn) ->
      expect(time).toEqual(100)
      fn()

    checkout = spyOn(ChiScore.Services, "checkOutTeam").and.callFake (id, fn) ->
      fn({ success: true })

    view.$el.find('.check-out-link').trigger('click')

    expect(checkout).toHaveBeenCalledWith('team-id', jasmine.any(Function))
    expect(removeTeam).toHaveBeenCalled()

  it 'deals with an unsuccesful checkout', ->
    view.render()

    errorDialog = spyOn(window, "alert")
    checkout = spyOn(ChiScore.Services, "checkOutTeam").and.callFake (id, fn) ->
      fn({ success: false })

    view.$el.find('.check-out-link').trigger('click')

    expect(checkout).toHaveBeenCalledWith('team-id', jasmine.any(Function))
    expect(errorDialog).toHaveBeenCalled()

  it 'flags a team', ->
    view.render()
    spyOn(window, "confirm").and.callFake -> true

    flag = spyOn(ChiScore.Services, "flagTeam")
    view.$el.find('.smiley').trigger('click')

    expect(flag).toHaveBeenCalledWith("team-id")

  it 'allows a user to cancel out of flagging a team', ->
    view.render()
    spyOn(window, "confirm").and.callFake -> false

    flag = spyOn(ChiScore.Services, "flagTeam")
    view.$el.find('.smiley').trigger('click')

    expect(flag).not.toHaveBeenCalled()
