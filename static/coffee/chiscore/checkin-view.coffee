class ChiScore.CheckinView extends Backbone.View
  template: EJS['checkin']
  _render: -> this.template({ checkin: this.checkin.attributes })

  render: ->
    this.setElement($(this._render()))
    return this.$el

  constructor: (checkin) ->
    this.checkin = checkin
    update = $.proxy(this.updateTime, this)
    checkin.on 'change:time', update

  events:
    'click .check-out-link' : 'checkout'
    'click .smiley'         : 'flag'

  updateTime: ->
    this.$el.find('.team-time').
      html(this.getTime()).
      addClass(this.timeClass())

  getTime: -> ChiScore.util.displayableTime(this.checkin.get('time'))

  getTeam: -> this.checkin.get('team')

  timeClass: ->
    time = this.checkin.get('time')

    return if time > 120
    if time <= 0 then 'out' else 'warning'

  checkout: (ev) ->
    ChiScore.Services.checkOutTeam this.getTeam().id, (response) =>
      if response.success
        this.$el.slideUp 100, -> $(this).remove()
      else
        alert("You can't check out that team yet!")

  flag: (ev) ->
    if confirm("Are you sure you want to flag this team? :)")
      ChiScore.Services.flagTeam(this.getTeam().id)
