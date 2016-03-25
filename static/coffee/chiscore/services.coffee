ChiScore.Services =
  getTimes : (fn) -> $.get('/api/checkins', fn, 'json')

  getActiveTeams : (checkpointId, fn) ->
    this._post('/api/checkins', {checkpoint : checkpointId }, fn, 'json')

  earlyCheckOut : (checkpointId, teamId, fn) ->
    this._post('/api/checkins/checkout', { checkpoint : checkpointId , team_id : teamId }, fn)

  flagTeam : (teamId) -> $.post('api/flags/flag_team', { team_id : teamId })

  checkInTeam : (teamId, fn) ->
    this._post('/api/checkins/checkin', { team_id : teamId }, fn)

  checkOutTeam : (teamId, fn) ->
    this._post('/api/checkins/checkout', { team_id : teamId }, fn)

  publicTimes: (checkpointId, fn) ->
    $.get("/public/checkpoint/#{checkpointId}/times", fn, 'json')

  deleteCheckin : (checkpointId, teamId, fn) ->
    this._post('/api/checkins/destroy', { checkpoint: checkpointId , team_id : teamId }, fn)

  _post : (url, data, callback) ->
    $.ajax({
      url : url
      type: "POST"
      data: data
      success: callback
      dataType: 'json'
      statusCode: { 404 : -> alert("Couldn't find that team. Read better.") }
    })
