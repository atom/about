{CompositeDisposable} = require 'atom'

AboutView = null
StatusBarView = null

# The local storage key for the available update version.
AvailableUpdateVersion = 'about:version-available'
AboutURI = 'atom://about'

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable
    @updateAvailable = false
    @aboutView = null
    @statusBarTile = null

    @subscriptions.add atom.workspace.addOpener (uriToOpen) =>
      if uriToOpen is AboutURI
        @deserializeAboutView(uri: AboutURI)

    @subscriptions.add atom.commands.add 'atom-workspace', 'about:view-release-notes', ->
      require('shell').openExternal('https://github.com/atom/atom/releases/tag/v'+atom.getVersion())

    availableVersion = localStorage.getItem(AvailableUpdateVersion)
    localStorage.removeItem(AvailableUpdateVersion) if availableVersion is atom.getVersion()

    if atom.isReleasedVersion()
      @subscriptions.add atom.onUpdateAvailable ({releaseVersion}) =>
        localStorage.setItem(AvailableUpdateVersion, releaseVersion)
        @showStatusBarIfNeeded()

  deactivate: ->
    @aboutView?.remove()
    @aboutView = null

    @subscriptions.dispose()
    @statusBarTile?.destroy()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar
    @showStatusBarIfNeeded()

  deserializeAboutView: (state) ->
    unless @aboutView?
      AboutView ?= require './about-view'
      @aboutView = new AboutView(uri: AboutURI)
    @aboutView

  isUpdateAvailable: ->
    availableVersion = localStorage.getItem(AvailableUpdateVersion)
    availableVersion? and availableVersion isnt atom.getVersion()

  showStatusBarIfNeeded: ->
    return unless @isUpdateAvailable() and @statusBar?

    StatusBarView ?= require './about-status-bar'

    @statusBarTile?.destroy()
    @statusBarTile = @statusBar.addRightTile(item: new StatusBarView(), priority: -100)

unless parseFloat(atom.getVersion()) >= 1.7
  atom.deserializers.add
    name: 'AboutView'
    deserialize: module.exports.deserializeAboutView.bind(module.exports)
