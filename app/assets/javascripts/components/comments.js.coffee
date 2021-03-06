
App.components.comments = ->
  attributes: ->
    list:        @container.find('#comments-list')
    identifier: 'remoteForm:comment-form'

  initialize: ->
    App.mediator.subscribe 'remoteForm:success', @onSuccess.bind(this)

  onSuccess: (evt, data) ->
    if data.identifier is @attr.identifier
      @cleanEditor()
      @addToList data.response.comment_html
      App.utils.flashMessage data.response.flash

  addToList: (comment_html) ->
    @attr.list.prepend $(comment_html)

  cleanEditor: ->
    App.mediator.publish 'editor:clean', {identifier: 'editor:comment_comment'}
