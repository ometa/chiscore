this["EJS"] = this["EJS"] || {};

this["EJS"]["checkin"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<li data-team-id="' +
((__t = ( checkin.team.id )) == null ? '' : __t) +
'">\n  <span class="smiley">☺ </span>\n  <span class="team-name">' +
((__t = ( checkin.team.name )) == null ? '' : __t) +
'</span>\n  <span class="team-time">\n    ' +
((__t = ( ChiScore.util.displayableTime(checkin.time) )) == null ? '' : __t) +
'\n  </span>\n\n  ';
 if(!ChiScore.isPublic || ChiScore.canEarlyCheckout(checkin.time)) { ;
__p += '\n    <div class="check-out-link">&#x2715;</div>\n  ';
 } ;
__p += '\n</li>\n';

}
return __p
};