(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ChiScore.Checkin = (function(_super) {
    __extends(Checkin, _super);

    function Checkin() {
      return Checkin.__super__.constructor.apply(this, arguments);
    }

    Checkin.prototype.defaults = {
      team: {
        name: ''
      },
      time: 25 * 60
    };

    Checkin.prototype.tick = function() {
      var time;
      time = this.get('time');
      if (time > 0) {
        return this.set('time', time - 1);
      }
    };

    return Checkin;

  })(Backbone.Model);

}).call(this);
