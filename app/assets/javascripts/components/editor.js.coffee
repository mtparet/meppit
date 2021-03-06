#= require tinymce

App.components.editor = ->
  attributes: ->
    pluginOptions:
      theme: 'modern'
      menubar: false
      statusbar: false
      height: @attr.height || 200
      language: $('body').data('locale').replace('-', '_')
      selector: "textarea##{@container.attr('id')}"

  initialize: ->
    window.tm = tinyMCE
    tinyMCE.init(_.extend @attr.pluginOptions, {
      setup: (ed) =>
        ed.on 'change', _.debounce(@onEditorChange).bind(this)
        ed.on 'init', () => App.mediator.publish 'component:initialized', this
    })
    App.mediator.subscribe 'editor:clean', @clean.bind(this)

  onEditorChange: (ed)->
    App.mediator.publish 'tinymce:changed', {id: @container.attr('id'), content: ed.target.getContent()}

  clean: (evt, data) ->
    if data.identifier is @identifier
      tinyMCE.get(@container.attr('id')).setContent ''

