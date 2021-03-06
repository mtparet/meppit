#= require spec_helper

describe "tabs", ->
  beforeEach ->
    @container = $ JST['templates/tabs']()

  it 'initializes component', ->
    spy App.components, 'tabs', =>
      App.mediator.publish 'components:start', @container
      expect(App.components.tabs).to.be.called


  describe 'component', ->
    beforeEach ->
      @component = _base.startComponent 'tabs', @container

    it 'calls jquery-ui.tabs plugin', ->
      spy @component.container, 'tabs', =>
        @component.initialize()
        expect(@component.container.tabs).to.be.called
