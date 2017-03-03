(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ChiScore.CheckinView = (function(_super) {
    __extends(CheckinView, _super);

    CheckinView.prototype.template = EJS['checkin'];

    CheckinView.prototype._render = function() {
      return this.template({
        checkin: this.checkin.attributes
      });
    };

    CheckinView.prototype.render = function() {
      this.setElement($(this._render()));
      return this.$el;
    };

    function CheckinView(checkin) {
      var update;
      this.checkin = checkin;
      update = $.proxy(this.updateTime, this);
      checkin.on('change:time', update);
    }

    CheckinView.prototype.events = {
      'click .check-out-link': 'checkout',
      'click .smiley': 'flag'
    };

    CheckinView.prototype.updateTime = function() {
      return this.$el.find('.team-time').html(this.getTime()).addClass(this.timeClass());
    };

    CheckinView.prototype.getTime = function() {
      return ChiScore.util.displayableTime(this.checkin.get('time'));
    };

    CheckinView.prototype.getTeam = function() {
      return this.checkin.get('team');
    };

    CheckinView.prototype.timeClass = function() {
      var time;
      time = this.checkin.get('time');
      if (time > 120) {
        return;
      }
      if (time <= 0) {
        return 'out';
      } else {
        return 'warning';
      }
    };

    CheckinView.prototype.checkout = function(ev) {
      var time;
      time = this.checkin.get('time');
      if (time < 1300) {
        return ChiScore.Services.checkOutTeam(this.getTeam().id, (function(_this) {
          return function(response) {
            if (response.success) {
              return _this.$el.slideUp(100, function() {
                return $(this).remove();
              });
            } else {
              return alert("You can't check out that team yet!");
            }
          };
        })(this));
      } else {
        if (confirm("Are you sure you want to DELETE this checkin? This should only be done if they were checked in by mistake.")) {
          return ChiScore.Services.deleteCheckin(null, this.getTeam().id, (function(_this) {
            return function(response) {
              if (response.destroyed === true) {
                return _this.$el.slideUp(100, function() {
                  return $(this).remove();
                });
              } else {
                return alert("You can't delete this checkin");
              }
            };
          })(this));
        }
      }
    };

    CheckinView.prototype.flag = function(ev) {
      if (confirm("Are you sure you want to flag this team? :)")) {
        return ChiScore.Services.flagTeam(this.getTeam().id);
      }
    };

    return CheckinView;

  })(Backbone.View);

}).call(this);
