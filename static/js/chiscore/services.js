(function() {
  ChiScore.Services = {
    getTimes: function(fn) {
      return $.get('/api/checkins', fn, 'json');
    },
    getActiveTeams: function(checkpointId, fn) {
      return this._post('/api/checkins', {
        checkpoint: checkpointId
      }, fn, 'json');
    },
    earlyCheckOut: function(checkpointId, teamId, fn) {
      return this._post('/api/checkins/checkout', {
        checkpoint: checkpointId,
        team_id: teamId
      }, fn);
    },
    flagTeam: function(teamId) {
      return $.post('api/flags/flag_team', {
        team_id: teamId
      });
    },
    checkInTeam: function(teamId, fn) {
      return this._post('/api/checkins/checkin', {
        team_id: teamId
      }, fn);
    },
    checkOutTeam: function(teamId, fn) {
      return this._post('/api/checkins/checkout', {
        team_id: teamId
      }, fn);
    },
    publicTimes: function(checkpointId, fn) {
      return $.get("/public/checkpoint/" + checkpointId + "/times", fn, 'json');
    },
    deleteCheckin: function(checkpointId, teamId, fn) {
      return this._post('/api/checkins/destroy', {
        checkpoint: checkpointId,
        team_id: teamId
      }, fn);
    },
    _post: function(url, data, callback) {
      return $.ajax({
        url: url,
        type: "POST",
        data: data,
        success: callback,
        dataType: 'json',
        statusCode: {
          404: function() {
            return alert("Couldn't find that team. Read better.");
          }
        }
      });
    }
  };

}).call(this);
