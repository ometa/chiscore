(function() {
  ChiScore.CheckinBoardView = (function() {
    function CheckinBoardView(parentElement) {
      this.parentElement = parentElement != null ? parentElement : $("ul#checkins");
    }

    CheckinBoardView.prototype.init = function(board) {
      var checkin, _i, _len, _ref;
      this.board = board;
      this.reset();
      _ref = this.board.checkins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        checkin = _ref[_i];
        this.appendCheckin(checkin);
      }
      this.bindCheckout();
      return this.bindCheckin();
    };

    CheckinBoardView.prototype.sync = function(board) {
      var checkin, _i, _len, _ref;
      this.board = board;
      this.reset();
      _ref = this.board.checkins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        checkin = _ref[_i];
        this.appendCheckin(checkin);
      }
      return this.bindCheckout();
    };

    CheckinBoardView.prototype.render = function(checkin) {
      return this._render({
        checkin: checkin
      });
    };

    CheckinBoardView.prototype._render = function(obj) {
      return window.EJS.checkin(obj);
    };

    CheckinBoardView.prototype.reset = function() {
      return this.parentElement.children('li').remove();
    };

    CheckinBoardView.prototype.appendCheckin = function(checkin) {
      return this.parentElement.append(this.render(checkin));
    };

    CheckinBoardView.prototype.update = function(checkin) {
      var spanner;
      spanner = this.parentElement.find("li[data-team-id='" + checkin.team.id + "'] span.team-time");
      spanner.html(ChiScore.util.displayableTime(checkin.time));
      if (checkin.time <= 0) {
        spanner.addClass('out');
        return spanner.removeClass('warning');
      } else if (checkin.time < 120) {
        return spanner.addClass('warning');
      }
    };

    CheckinBoardView.prototype.bindCheckout = function() {
      $("span.smiley").on("click", function(e) {
        var teamId;
        if (confirm("Are you sure you want to flag this team as a smiley team?")) {
          teamId = $(this).parent('li').attr('data-team-id');
          return ChiScore.Services.flagTeam(teamId);
        }
      });
      return $("div.check-out-link").on("click", function(e) {
        var teamId;
        e.preventDefault();
        teamId = $(this).parent('li').attr('data-team-id');
        return ChiScore.Services.checkOutTeam(teamId, function(response) {
          if (response.success === true) {
            return $("li[data-team-id=" + response.team.id + "]").slideUp(100, function() {
              return $(this).remove();
            });
          } else {
            return alert("You can't check out that team yet!");
          }
        });
      });
    };

    CheckinBoardView.prototype.bindCheckin = function() {
      return $("form#checkin").bind("submit", (function(_this) {
        return function(e) {
          e.preventDefault();
          _this.board.createCheckin($(".sign-up-input").val());
          return $(".sign-up-input").val("");
        };
      })(this));
    };

    return CheckinBoardView;

  })();

  ChiScore.CheckinBoard = (function() {
    function CheckinBoard() {
      this.checkins = [];
      this.view = new ChiScore.CheckinBoardView();
    }

    CheckinBoard.prototype.init = function() {
      return this.sync((function(_this) {
        return function() {
          return _this.view.init(_this);
        };
      })(this));
    };

    CheckinBoard.prototype.reset = function() {
      return this.sync((function(_this) {
        return function() {
          return _this.view.sync(_this);
        };
      })(this));
    };

    CheckinBoard.prototype.sync = function(fn) {
      return ChiScore.Services.getTimes((function(_this) {
        return function(response) {
          _this.checkins = response;
          if (fn) {
            return fn();
          }
        };
      })(this));
    };

    CheckinBoard.prototype.tick = function() {
      var checkin, _i, _len, _ref, _results;
      _ref = this.checkins;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        checkin = _ref[_i];
        if (checkin.time > 0) {
          checkin.time -= 1;
          _results.push(this.view.update(checkin));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    CheckinBoard.prototype.createCheckin = function(teamId) {
      return ChiScore.Services.checkInTeam(teamId, (function(_this) {
        return function(checkin) {
          var time;
          if (checkin.success === true) {
            _this.checkins.push(checkin);
            return _this.view.appendCheckin(checkin);
          } else {
            time = ChiScore.util.displayableTime(checkin.time);
            return alert("That team has " + time + " left at " + checkin.checkpoint.name + ". Tell them to stop cheating");
          }
        };
      })(this));
    };

    return CheckinBoard;

  })();

}).call(this);
