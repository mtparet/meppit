# Event bus for using pub/sub
mediator =
  obj: $({})
  publish: (channel, data) -> @obj.trigger(channel, data)
  subscribe: (channel, fn) -> @obj.bind(channel, fn)
  unsubscribe: (channel, fn) -> @obj.unbind(channel, fn)

# "async" functions. Returns a deferred object.
asyncFn = (fn) ->
  deferred = $.Deferred()
  setTimeout( ->
    args = fn()
    deferred.resolve(args)
  , 0)
  deferred

# components namespaces
components = { _instances: {} }

# random id generator for components without id
_randomId = ->
  Math.random().toString(36).substring(7)

# component id
_compId = (name, container) ->
  "#{name}:#{container.attr('id') || _randomId()}"

# Initialize a component and add the instance to the container data
setupContainer = (container) ->
  container = $(container) unless container.jquery
  names = container.data('components').split /\s+/
  _.each names, (name) =>
    component = components[name]?(container)
    asyncFn ->  component.init()
    .then   ->  components._instances[_compId(name, container)] = component


# setup all components for a DOM root
startComponents = (evt, root=document) ->
  $(root).find('[data-components]').each (i, container) =>
    setupContainer(container)


mediator.subscribe 'components:start', startComponents

# setup global App namesmpace
window.App =
  mediator: mediator
  utils: {}
  components: components


# setup testing ns
window.__testing__?.base =
  startComponents: startComponents
  setupContainer : setupContainer
