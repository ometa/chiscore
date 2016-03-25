(function() {
  ChiScore.ActiveBoardView = (function() {
    function ActiveBoardView(parentElement) {
      this.parentElement = parentElement;
    }

    ActiveBoardView.prototype.init = function(checkpoint) {
      var checkin, _i, _len, _ref;
      _ref = checkpoint.checkins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        checkin = _ref[_i];
        this.appendCheckin(checkin, checkpoint);
      }
      this.bindCheckout();
      return this.bindDestroyCheckin();
    };

    ActiveBoardView.prototype.render = function(checkin, checkpoint) {
      return this._render({
        checkin: checkin,
        checkpoint: checkpoint
      });
    };

    ActiveBoardView.prototype._render = function(obj) {
      return window.EJS.checkout(obj);
    };

    ActiveBoardView.prototype.appendCheckin = function(checkin, checkpoint) {
      return this.parentElement.append(this.render(checkin, checkpoint));
    };

    ActiveBoardView.prototype.bindCheckout = function() {
      $("a.check-out-link").unbind();
      return $("a.check-out-link").on("click", function(e) {
        var checkpointId, teamId;
        e.preventDefault();
        teamId = $(this).parent('li').attr('data-team-id');
        checkpointId = $(this).parent('li').attr('data-checkpoint-id');
        return ChiScore.Services.earlyCheckOut(checkpointId, teamId, function(response) {
          if (response.success === true) {
            return $("li[data-team-id=" + response.team.id + "]").slideUp(100, function() {
              return $(this).remove();
            });
          }
        });
      });
    };

    ActiveBoardView.prototype.bindDestroyCheckin = function() {
      var _this;
      _this = this;
      $("a.destroy-checkin").unbind();
      return $("a.destroy-checkin").on("click", function(e) {
        var checkpointId, teamId;
        e.preventDefault();
        teamId = $(this).parent('li').attr('data-team-id');
        checkpointId = $(this).parent('li').attr('data-checkpoint-id');
        if (_this.getConfirmation() === true) {
          return ChiScore.Services.deleteCheckin(checkpointId, teamId, (function(_this) {
            return function(response) {
              if (response.destroyed === true) {
                return $("li[data-team-id=" + response.team.id + "]").slideUp(100, function() {
                  return $(this).remove();
                });
              }
            };
          })(this));
        }
      });
    };

    ActiveBoardView.prototype.getConfirmation = function() {
      return confirm("Are you sure you want to delete this checkin? It could have some very serious consequences for the team");
    };

    return ActiveBoardView;

  })();

  ChiScore.ActiveBoard = (function() {
    function ActiveBoard(checkpointId) {
      var checkpointElement;
      this.checkpointId = checkpointId;
      checkpointElement = $("ul#checkpoint" + this.checkpointId);
      this.checkins = [];
      this.view = new ChiScore.ActiveBoardView(checkpointElement);
    }

    ActiveBoard.prototype.init = function() {
      return this.sync((function(_this) {
        return function() {
          return _this.view.init(_this);
        };
      })(this));
    };

    ActiveBoard.prototype.sync = function(fn) {
      return ChiScore.Services.getActiveTeams(this.checkpointId, (function(_this) {
        return function(response) {
          _this.checkins = response;
          if (fn) {
            return fn();
          }
        };
      })(this));
    };

    return ActiveBoard;

  })();

}).call(this);
