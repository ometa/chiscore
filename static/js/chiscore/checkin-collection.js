(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ChiScore.CheckinCollection = (function(_super) {
    __extends(CheckinCollection, _super);

    function CheckinCollection() {
      return CheckinCollection.__super__.constructor.apply(this, arguments);
    }

    CheckinCollection.prototype.model = ChiScore.Checkin;

    CheckinCollection.prototype.comparator = function(checkin) {
      return checkin.get('time');
    };

    return CheckinCollection;

  })(Backbone.Collection);

}).call(this);
