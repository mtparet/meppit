#= require jquery.modal

App.components.modal = (container) ->
  attributes: ->
    target: @getTarget()
    defaults:
      fadeDuration: 150
      zIndex: 200
      showSpinner: false  # this is buggy, so we do manually
      modalClass: @attr.modal_class || "modal"
      identifier: @identifier
    preventCloseOpts:
      escapeClose: false
      clickClose: false
      closeText: ''
      showClose: false

  initialize: ->
    if @attr.autoload then @open() else @on 'click', @open
    App.mediator.subscribe 'modal:open', @onOpen.bind(this)

  getTarget: ->
    if @attr.remote || @attr.autoload then @container else @referedElement()

  referedElement: ->
    $("#{ @container.attr('href') }")

  open: () ->
    if @shouldOpen()
      App.utils.spinner.show() if @attr.remote
      @attr.target.modal @pluginOptions()
    false

  onOpen: (evt, data)->
    return unless @identifier is data.identifier

    App.utils.spinner.hide()
    if @attr.remote
      currentModal = $('.modal.current')
      App.mediator.publish('components:start', currentModal)

  pluginOptions: ->
    closeOptions = if @attr.prevent_close then  @attr.preventCloseOpts else {}
    _.extend {}, @attr.defaults, closeOptions

  shouldOpen: ->
    (!@attr.login_required) || (@attr.login_required && @loggedIn())

  loggedIn: ->
    !!$.cookie('logged_in')
