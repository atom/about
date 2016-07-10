{CompositeDisposable} = require 'atom'

AboutView = null
StatusBarView = null
UpdateManager = null
updateManager = null

# The local storage key for the available update version.
AvailableUpdateVersion = 'about:version-available'
AboutURI = 'atom://about'

getUpdateManager = ->
  unless updateManager?
    UpdateManager ?= require './update-manager'
    debugger
    updateManager = new UpdateManager
  updateManager

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
      updateManager = getUpdateManager()
      {shell} = require 'electron'
      shell.openExternal(updateManager.getReleaseNotesURLForCurrentVersion())

    availableVersion = localStorage.getItem(AvailableUpdateVersion)
    localStorage.removeItem(AvailableUpdateVersion) if availableVersion is atom.getVersion()

    if atom.isReleasedVersion()
      @subscriptions.add atom.onUpdateAvailable ({releaseVersion}) =>
        localStorage.setItem(AvailableUpdateVersion, releaseVersion)
        @showStatusBarIfNeeded()

  deactivate: ->
    @aboutView?.destroy()
    @aboutView = null

    updateManager?.dispose()
    updateManager = null

    @subscriptions.dispose()
    @statusBarTile?.destroy()

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar
    @showStatusBarIfNeeded()

  deserializeAboutView: (state) ->
    unless @aboutView?
      AboutView ?= require './about-view.js'
      updateManager = getUpdateManager()
      debugger
      @aboutView = new AboutView({
        uri: AboutURI,
        updateManager,
        availableVersion: updateManager.getAvailableVersion()
      })
    debugger
    @aboutView

  isUpdateAvailable: ->
    availableVersion = localStorage.getItem(AvailableUpdateVersion)
    availableVersion? and availableVersion isnt atom.getVersion()

  showStatusBarIfNeeded: ->
    return unless @isUpdateAvailable() and @statusBar?

    StatusBarView ?= require './about-status-bar-ng'

    statusBarView = new StatusBarView()
    @statusBarTile?.destroy()
    @statusBarTile = @statusBar.addRightTile(item: statusBarView, priority: -100)
