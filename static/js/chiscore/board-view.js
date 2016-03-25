(function() {
  var appendCheckin,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  appendCheckin = function(el, checkin) {
    return el.append(checkin.render());
  };

  ChiScore.SubmitView = (function(_super) {
    __extends(SubmitView, _super);

    function SubmitView() {
      return SubmitView.__super__.constructor.apply(this, arguments);
    }

    SubmitView.prototype.initialize = function(opts) {
      return this.boardView = opts.boardView;
    };

    SubmitView.prototype.events = {
      "submit form#checkin": "createCheckin"
    };

    SubmitView.prototype.createCheckin = function(ev) {
      var input, teamId;
      ev.preventDefault();
      input = this.$el.find('.sign-up-input');
      teamId = input.val();
      input.val("");
      return ChiScore.Services.checkInTeam(teamId, (function(_this) {
        return function(resp) {
          var time;
          if (resp.success === true) {
            return _this.boardView.addCheckin(resp);
          } else {
            time = ChiScore.util.displayableTime(resp.time);
            return alert(("That team still has " + time + " left at " + resp.checkpoint.name + " ") + "Tell them to stop cheating.");
          }
        };
      })(this));
    };

    return SubmitView;

  })(Backbone.View);

  ChiScore.BoardView = (function(_super) {
    __extends(BoardView, _super);

    function BoardView(options) {
      this.setElement(options.el || $('ul#checkins'));
      this.useCheckins(options.checkins);
      this.submitView = new ChiScore.SubmitView({
        el: $('body'),
        boardView: this
      });
    }

    BoardView.prototype.render = function() {
      return _.each(this.checkinViews, (function(_this) {
        return function(view) {
          return appendCheckin(_this.$el, view);
        };
      })(this));
    };

    BoardView.prototype.reset = function() {
      return this.$el.children('li').remove();
    };

    BoardView.prototype.useCheckins = function(checkins) {
      this.checkins = checkins;
      return this.checkinViews = this.checkins.map(function(checkin) {
        return new ChiScore.CheckinView(checkin);
      });
    };

    BoardView.prototype.tick = function() {
      return _.each(this.checkinViews, (function(_this) {
        return function(view) {
          var checkin;
          checkin = view.checkin;
          checkin.tick();
          return view.updateTime();
        };
      })(this));
    };

    BoardView.prototype.addCheckin = function(resp) {
      var checkin, view;
      checkin = new ChiScore.Checkin(resp);
      view = new ChiScore.CheckinView(checkin);
      appendCheckin(this.$el, view);
      this.checkins.add(checkin);
      return this.checkinViews.push(view);
    };

    BoardView.prototype.sync = function(checkpointId) {
      var fn;
      if (checkpointId == null) {
        checkpointId = null;
      }
      fn = null;
      if (checkpointId != null) {
        fn = _.partial(ChiScore.Services.publicTimes, checkpointId);
      } else {
        fn = ChiScore.Services.getTimes;
      }
      return fn((function(_this) {
        return function(response) {
          var checkins;
          checkins = new ChiScore.CheckinCollection(response);
          _this.useCheckins(checkins);
          _this.reset();
          return _this.render();
        };
      })(this));
    };

    return BoardView;

  })(Backbone.View);

}).call(this);
