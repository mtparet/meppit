expanded = """
<i class="fa fa-chevron-up"></i> #{I18n.lists.collapse}
"""
collapsed = """
<i class="fa fa-chevron-down"></i> #{I18n.lists.expand}
"""

App.components.listFilter = ->
  attributes: ->
    toggleBtn:    @container.find('.toggle-panel')
    filtersForm:  @container.find('.filters')
    filterChoice: @container.find('input[data-filter]')
    sortChoice:   @container.find('.choice input[type=radio]')
    tags:         @container.find('input#filter_tags')
    tagsId:       'tags:filter_tags'

  initialize: ->
    @on @attr.toggleBtn,    'click', @toggle
    @on @attr.filterChoice, 'click', @toggleFilter

    @on @attr.sortChoice,  'click',        @sortChanged
    App.mediator.subscribe 'tags:changed', @tagsChanged.bind(this)

  toggle: ->
    if @isExpanded() then @collapse() else @expand()

  isExpanded: ->
    @attr.toggleBtn.data('toggle') is 'expanded'

  collapse: ->
    @attr.filtersForm.slideUp('fast')
    @attr.toggleBtn.data('toggle', 'collapsed')
    @attr.toggleBtn.html collapsed

  expand: ->
    @attr.filtersForm.slideDown('fast')
    @attr.toggleBtn.data('toggle', 'expanded')
    @attr.toggleBtn.html expanded

  toggleFilter: (evt)->
    el = $ evt.target
    panel = @container.find el.data('filter')
    panel.slideToggle 'fast'

  sortChanged: (evt) ->
    console.log 'sortChanged'

  tagsChanged: (evt, data) ->
    if data.identifier is @attr.tagsId
      console.log 'tagsChanged', evt, data
