{CompositeDisposable} = require 'atom'

StatusBarView = null

# The local storage key for the available update version.
AvailableUpdateVersion = 'about:version-available'

AboutURI = 'atom://about'

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable
    @updateAvailable = false

    @subscriptions.add atom.workspace.addOpener (uriToOpen) ->
      if uriToOpen is AboutURI
        createAboutView = require './about-view'
        createAboutView(uri: uriToOpen)

    @subscriptions.add atom.commands.add 'atom-workspace', 'about:view-release-notes', ->
      require('shell').openExternal('https://atom.io/releases')

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
