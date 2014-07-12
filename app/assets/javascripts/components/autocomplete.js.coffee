App.components.autocomplete = (container) ->
  {
    container: container

    init: ->
      @data = @container.data("component-options")
      @startPlugin()

    autocompleteTarget: ->
      $("##{@container.name}_autocomplete");

    onSelect: (event, ui) ->
      value = ui.item?.id || ""
      console.log value
      @autocompleteTarget().val(value)

    startPlugin: ->
      _this = this
      @container.autocomplete({
        minLength: 2
        source:    _this.data.url
        select:    _this.onSelect.bind(_this)
      })

  }
