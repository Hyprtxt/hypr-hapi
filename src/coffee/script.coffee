console.log 'script loaded'

Beer = Backbone.Model.extend
  defaults:
    id: 0
    name: 'Lobrau'
    likes: 0
    drunk: false

Cooler = Backbone.Collection.extend
  model: Beer

# tapHouse = 'http://beer.fluentcloud.com/v1/beer'
tapHouse = 'http://localhost:8080/'

$.ajax tapHouse,
  success: ( data ) ->
    return new CoolerView collection: new Cooler data

BeerView = Backbone.View.extend
  tagName: 'div'
  template: _.template $('#beerTemplate').html()
  initialize: ->
    this.render()
    return this
  render: ->
    this.$el.html this.template this.model.toJSON()
    return this
  events:
    'click .btn': 'likeBeer'
  likeBeer: ->
    likes = parseInt this.model.get 'likes'
    this.model.set 'likes', likes + 1
    this.render()
    return this

CoolerView = Backbone.View.extend
  el: '#container'
  template: _.template $('#beerTemplate').html()
  initialize: ->
    this.render()
    return this
  render: ->
    this.$el.html ''
    this.collection.each ( beer ) ->
      beerView = new BeerView model: beer, className: 'card col-md-4'
      this.$el.append beerView.el
    , this
    return this
