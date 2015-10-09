console.log 'script loaded'

CoolerView = Backbone.View.extend
  el: '#container'
  template: _.template "<h3>Hello <%= who %></h3>"
  initialize: ->
    this.render()
  render: ->
    this.$el.html this.template who: "World!"

CoolerView = new CoolerView()
