{CompositeDisposable} = require 'atom'

AboutView = null
StatusBarView = null

aboutURI = 'atom://about'

createAboutView = (state) ->
  AboutView ?= require './about-view'
  new AboutView(state)

atom.deserializers.add
  name: 'AboutView'
  deserialize: (state) -> createAboutView(state)

module.exports = About =
  activate: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.workspace.addOpener (uriToOpen) ->
      createAboutView(uri: uriToOpen) if uriToOpen is aboutURI

    @subscriptions.add atom.commands.add 'atom-workspace', 'about:view-release-notes', ->
      require('shell').openExternal('https://atom.io/releases')

    if atom.isReleasedVersion()
      @subscriptions.add atom.commands.add 'atom-workspace', 'window:update-available', =>
        @updateAvailable = true
        @showStatusBarIfNeeded()

  deactivate: ->
    @subscriptions.dispose()
    @statusBarView?.remove()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar
    @showStatusBarIfNeeded()

  showStatusBarIfNeeded: ->
    return unless @updateAvailable and @statusBar?

    StatusBarView ?= require './about-status-bar'

    @statusBarView?.remove()
    @statusBarView = new StatusBarView()
    @statusBar.addRightTile(item: @statusBarView, priority: -100)
