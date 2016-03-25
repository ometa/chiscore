describe "ChiScore.Services", ->
  fn = -> undefined

  it "gets the times for the given checkpoint", ->
    spyOn($, "get")
    ChiScore.Services.getTimes(fn)
    expect($.get).toHaveBeenCalledWith "/api/checkins", fn, "json"

  it "checks in a team for the given checkpoint", ->
    spyOn($, "ajax")
    ChiScore.Services.checkInTeam(2, fn)
    expect($.ajax).toHaveBeenCalledWith(jasmine.objectContaining({
      url: "/api/checkins/checkin",
      data: { team_id : 2 },
      success: fn
    }))

  it "checks out a team for the given checkpoint", ->
    spyOn($, "ajax")
    ChiScore.Services.checkOutTeam(2, fn)
    expect($.ajax).toHaveBeenCalledWith(jasmine.objectContaining({
      url: "/api/checkins/checkout",
      data: { team_id : 2 },
      success: fn
    }))

  it "gets the active teams for the posted checkpoint", ->
    spyOn($, "ajax")
    ChiScore.Services.getActiveTeams(1, fn)
    expect($.ajax).toHaveBeenCalledWith(jasmine.objectContaining({
      url: "/api/checkins",
      data: {checkpoint : 1},
      success: fn
    }))

  it "checks out the team for for a checkpoint provided by admin", ->
    spyOn($, "ajax")
    ChiScore.Services.earlyCheckOut(1, 2, fn)
    expect($.ajax).toHaveBeenCalledWith(jasmine.objectContaining({
      url: "/api/checkins/checkout",
      data: {checkpoint: 1, team_id: 2},
      success: fn
    }))

  it "destroys a checkin for a checkpoint provided by admin", ->
    spyOn($, "ajax")
    ChiScore.Services.deleteCheckin(1, 2, fn)
    expect($.ajax).toHaveBeenCalledWith(jasmine.objectContaining({
      url: "/api/checkins/destroy",
      data: {checkpoint: 1, team_id: 2},
      success: fn
    }))
