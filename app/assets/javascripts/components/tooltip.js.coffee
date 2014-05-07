#= require jquery.qtip

App.components.tooltip = (container) ->
  container: container

  init: () ->
    @data = @container.data('tooltip')
    content = $(@data.target)
    @startPlugin(content)

  onShow: ->
    @container.addClass 'active'
    App.mediator.publish 'components:start', $('.qtip-content')

  onHide: ->
    @container.removeClass 'active'

  startPlugin: (content) ->
    _this = this

    @container.qtip
      show: 'mousedown'
      content: content.html()
      style:
        classes: 'tooltip qtip-light qtip-shadow qtip-rounded'
      hide:
        event: 'unfocus'
      position:
        my: 'top center'
        adjust:
          x: -50, y: 5
      events:
        show: _this.onShow.bind(_this)
        hide: _this.onHide.bind(_this)

