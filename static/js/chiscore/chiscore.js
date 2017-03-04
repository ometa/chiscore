(function() {
  var ChiScore;

  ChiScore = window.ChiScore = {};

  ChiScore.Models = {};

  ChiScore.Collections = {};

  ChiScore.util = {
    displayableTime: function(stringTime) {
      var minutes, seconds, time;
      time = parseInt(stringTime);
      if (time < 1) {
        return "00:00";
      }
      minutes = Math.floor(time / 60);
      seconds = time % 60;
      if (seconds < 10) {
        seconds = "0" + seconds;
      }
      if (minutes < 10) {
        minutes = "0" + minutes;
      }
      return "" + minutes + ":" + seconds;
    },
    canEarlyCheckout: function(checkin) {
      var minutes;
      minutes = Math.floor(time / 60);
      return minutes <= 4;
    }
  };

  ChiScore.main = function() {
    if (!($('ul#checkins').length > 0)) {
      return;
    }
    if ($('ul#checkins').hasClass('checkpoint-checkins')) {
      ChiScore.checkinMain();
      return;
    }
    return ChiScore.Services.getTimes(function(resp) {
      var boardView, checkins, syncTicker, ticker;
      checkins = new ChiScore.CheckinCollection(resp);
      boardView = new ChiScore.BoardView({
        checkins: checkins
      });
      boardView.render();
      ticker = function() {
        return setTimeout((function() {
          boardView.tick();
          return ticker();
        }), 1000);
      };
      syncTicker = function() {
        return setTimeout((function() {
          boardView.sync();
          return syncTicker();
        }), 4000);
      };
      ticker();
      return syncTicker();
    });
  };

  ChiScore.checkinMain = function() {
    var checkpointId;
    checkpointId = $("ul#checkins").attr('data-checkpoint-id');
    ChiScore.isPublic = true;
    return ChiScore.Services.publicTimes(checkpointId, function(resp) {
      var boardView, checkins, syncTicker, ticker;
      checkins = new ChiScore.CheckinCollection(resp);
      boardView = new ChiScore.BoardView({
        checkins: checkins
      });
      boardView.render();
      ticker = function() {
        return setTimeout((function() {
          boardView.tick();
          return ticker();
        }), 1000);
      };
      syncTicker = function() {
        return setTimeout((function() {
          boardView.sync(checkpointId);
          return syncTicker();
        }), 10000);
      };
      ticker();
      return syncTicker();
    });
  };

}).call(this);
