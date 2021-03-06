#= require meppit-map

geometrySelection = ->
  template: JST['templates/mapGeometrySelector']

  init: (@attr, @action, @done) ->
    if @attr.geometryType
      @done @attr.geometryType
    else
      @el = $ @template(@attr.data)
      @bindEvents()
    this

  bindEvents: ->
    @el.find('.option').click @onOptionSelected.bind(this)

  onOptionSelected: (evt) ->
    evt.preventDefault()
    geometryType =  $(evt.target).data 'geometry-type'
    @el.hide()
    @done geometryType

locationSelection = ->
  template: JST['templates/mapLocationSelector']

  init: (@attr, @action, @done) ->
    @el = $ @template(@attr.data)
    @findElements()
    @bindEvents()
    if @attr.geolocation
      @locate()
    else
      @displayQuestion()
    this

  findElements: ->
    @questionEl     = @el.find("#location-selector-question")
    @instructionsEl = @el.find("#location-selector-instructions")

  bindEvents: ->
    @el.find('#location-selector-question .option').click @onQuestionOptionSelected.bind(this)

  displayQuestion: ->
    @questionEl.show()
    @instructionsEl.hide()

  displayInstructions: ->
    @questionEl.hide()
    @instructionsEl.show()

  displaySearch: ->
    # TODO: add search option
    @el.hide()
    @done()

  onQuestionOptionSelected: (evt) ->
    evt.preventDefault()
    isNear = $(evt.target).data 'is-near'
    if isNear then @locate() else @displaySearch()

  locate: ->
    timer = null
    onSuccess = (e) =>
      clearTimeout timer
      @el.hide()
      @done e.location
    onError = (e) =>
      clearTimeout timer
      @displaySearch()
    @action? onSuccess, onError
    @questionEl.hide()
    timer = setTimeout =>
      @displayInstructions()
    , 1000


drawAssistence = =>
  init: (@attr, @done)->
    @map = @attr.map
    @availableSteps = {
      geometrySelection: @geometrySelection,
      locationSelection: @locationSelection
    }
    @defaultSteps = _.keys @availableSteps
    @steps = (@availableSteps[step] for step in (@attr.steps ? @defaultSteps))
    @el = $ '<div>'
    @remainingSteps = @steps.slice()
    @goToNextStep()
    this

  goToNextStep: ->
    step = @remainingSteps.shift()
    if step
      step.bind(this)()
    else
      @onFinish()

  stepFinished:->
    @goToNextStep()

  onFinish: ->
    @el.hide()
    @done? {
      geometryType: @geometryType,
      location: @location
    }

  geometrySelection: ->
    done = (geometryType) =>
      @geometryType = geometryType
      @stepFinished()
    geometrySelection = geometrySelection().init @attr, null, done
    @el.prepend geometrySelection.el if geometrySelection.el

  locationSelection: ->
    action = => @map.locate.apply(@map, arguments)
    done = (location) =>
      @location = location
      @stepFinished()
    locationSelection = locationSelection().init @attr, action, done
    @el.prepend locationSelection.el if locationSelection.el


App.components.map = ->
  initialize: ->
    @startMap()
    @addButtons() if not @attr.embeded
    @autoLocate() if @attr.autoLocate
    @bindEvents()
    if not @embeded and @attr.editor and not @attr.hasLocation
      @startDrawAssistence()
    App.mediator.publish 'component:initialized', this

  startDrawAssistence: ->
    done = (content) =>
      @mapEl.show()
      @map.refresh()
      setTimeout =>
        @map.fit content.location
        @draw content.geometryType
      , 100
    @drawAssistence = drawAssistence().init _.extend(@attr, {map: @map}), done
    @container.prepend @drawAssistence.el
    @mapEl.hide()

  startMap: ->
    L.Icon.Default.imagePath = '/assets'
    window.map = this
    @mapEl = $('<div>').addClass('map-container')
    @container.append @mapEl
    groups = []
    # make sure the layer rules are correctly parsed
    if @attr.layers?
      for group in @attr.layers
        group.rule.value = JSON.parse(group.rule.value) if group.rule?.value?
        groups.push group
    @map = new Meppit.Map
      element: @mapEl[0],
      enableGeoJsonTile: @attr.enableGeoJsonTile
      featureURL: @attr.featureURL
      geojsonTileURL: "#{@attr.geojsonTileURL}#{window.location.search}"
      groups: groups
    feature = @attr.geojson or @attr.featuresIds
    if feature
      @show(feature, => @edit feature if @attr.editor)

  edit: (feature) ->
    @map.edit feature, @updateInput.bind(this)

  onDraw: (feature) ->
   @drawing = false
   @updateInput()
   @edit feature

  draw: (feature) ->
    return if @drawing
    @drawing = true
    @map.draw feature, @onDraw.bind(this)

  updateInput: ->
    $(@attr.inputSelector).val JSON.stringify(@map.toSimpleGeoJSON())

  show: (feature, callback) ->
    @map.show feature, =>
      @updateInput()
      callback?()

  bindEvents: ->
    App.mediator.subscribe 'remoteForm:beforeSubmit', @onBeforeFormSubmit.bind(this)
    $(window).resize @onWindowResize.bind(this)
    App.mediator.subscribe 'layer:show', @onLayerShow.bind(this)
    App.mediator.subscribe 'layer:hide', @onLayerHide.bind(this)

  onBeforeFormSubmit: ->
    @map.done()

  onWindowResize: ->
    @expand() if @expanded

  onLayerShow: (evt, data) ->
    @map.showLayer data.id

  onLayerHide: (evt, data) ->
    @map.hideLayer data.id

  addButtons: ->
    @map.addButton 'expand', 'fa-expand', @expand.bind(this), @attr.data['expand_button_title'], 'topright'
    @map.addButton 'collapse', 'fa-compress', @collapse.bind(this), @attr.data['collapse_button_title'], 'topright'
    @map.hideButton 'collapse'

  autoLocate: ->
    @map.locate (e) => @map.fit e.location

  expand: ->
    @_cloneLayersList()
    @layersList.show()
    @map.hideButton 'expand'
    @map.showButton 'collapse'
    if not @expanded
      @_sitePageOriginalPosition = $('.site-page').css('position')
      @_originalScrollTop = $(window).scrollTop()
      @_originalCss =
        position: @container.css('position')
        top: @container.css('top')
        left: @container.css('left')
        height: @container.css('height')
        width: @container.css('width')
        'z-index': @container.css('z-index')
      @map.zoomIn 1, animate: false
    top = $("#header").height()
    $(window).scrollTop(0)
    # make sure the map position is really absolute
    $('.site-page').css position: 'initial'
    @container.css
      position: 'absolute'
      top: top
      left: 0
      height: $(window).height() - top
      width: $(window).width()
      'z-index': 9
    @map.refresh()
    @expanded = true

  collapse: ->
    return if not @expanded
    @layersList.hide()
    @map.hideButton 'collapse'
    @map.showButton 'expand'
    $(window).scrollTop(@_originalScrollTop)
    $('.site-page').css position: @_sitePageOriginalPosition
    @container.css @_originalCss
    @map.zoomOut 1, animate: false
    @map.refresh()
    @expanded = false

  _cloneLayersList: ->
    return if @layersList?
    @layersList = $('#map-layers').clone()
    return if @layersList.length is 0
    App.mediator.publish('components:start', @layersList)
    @container.append @layersList
