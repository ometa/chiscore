this["EJS"] = this["EJS"] || {};

this["EJS"]["checkin"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<li data-team-id="' +
((__t = ( checkin.team.id )) == null ? '' : __t) +
'">\r\n  <span class="smiley">☺ </span>\r\n  <span class="team-id">' +
((__t = ( checkin.team.id )) == null ? '' : __t) +
'</span>\r\n  <span class="team-name">' +
((__t = ( checkin.team.name )) == null ? '' : __t) +
'</span>\r\n  <span class="team-time">\r\n    ' +
((__t = ( ChiScore.util.displayableTime(checkin.time) )) == null ? '' : __t) +
'\r\n  </span>\r\n\r\n  ';
 if(!ChiScore.isPublic || ChiScore.canEarlyCheckout(checkin.time)) { ;
__p += '\r\n    <div class="check-out-link">&#x2715;</div>\r\n  ';
 } ;
__p += '\r\n</li>\r\n';

}
return __p
};