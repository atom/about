{CompositeDisposable} = require 'atom'

AboutView = null
StatusBarView = null

# The local storage key for the available update version.
AvailableUpdateVersion = 'about:version-available'

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
    @updateAvailable = false

    @subscriptions.add atom.workspace.addOpener (uriToOpen) ->
      createAboutView(uri: uriToOpen) if uriToOpen is aboutURI

    @subscriptions.add atom.commands.add 'atom-workspace', 'about:view-release-notes', ->
      require('shell').openExternal('https://github.com/atom/atom/releases/tag/v'+atom.getVersion())

    availableVersion = localStorage.getItem(AvailableUpdateVersion)
    localStorage.removeItem(AvailableUpdateVersion) if availableVersion is atom.getVersion()

    if atom.isReleasedVersion()
      @subscriptions.add atom.onUpdateAvailable ({releaseVersion}) =>
        localStorage.setItem(AvailableUpdateVersion, releaseVersion)
        @showStatusBarIfNeeded()

  deactivate: ->
    @subscriptions.dispose()
    @statusBarTile?.destroy()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar
    @showStatusBarIfNeeded()

  isUpdateAvailable: ->
    availableVersion = localStorage.getItem(AvailableUpdateVersion)
    availableVersion? and availableVersion isnt atom.getVersion()

  showStatusBarIfNeeded: ->
    return unless @isUpdateAvailable() and @statusBar?

    StatusBarView ?= require './about-status-bar'

    @statusBarTile?.destroy()
    @statusBarTile = @statusBar.addRightTile(item: new StatusBarView(), priority: -100)
