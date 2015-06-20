{CompositeDisposable} = require 'atom'

AboutView = null
aboutView = null

aboutURI = 'atom://about'

createAboutView = (state) ->
  AboutView ?= require './about-view'
  aboutView ?= new AboutView(state)
  aboutView

module.exports = About =
  activate: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.workspace.addOpener (uriToOpen) ->
      createAboutView(uri: uriToOpen) if uriToOpen is aboutURI

    @subscriptions.add atom.commands.add 'atom-workspace', 'about:about-atom': ->
      atom.workspace.open(aboutURI)

  deactivate: ->
    @subscriptions.dispose()
