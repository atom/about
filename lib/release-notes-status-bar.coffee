{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
shell = require('shell')

module.exports =
class ReleaseNotesStatusBar extends View
  @content: ->
    @span type: 'button', class: 'release-notes-status icon icon-squirrel inline-block'

  initialize: (@statusBar, previousVersion) ->
    @subscriptions = new CompositeDisposable()

    @on 'click', ->
      shell.openExternal 'https://atom.io/releases'
    @subscriptions.add atom.commands.add 'atom-workspace', 'window:update-available', => @attach()

    @subscriptions.add atom.tooltips.add(@element, title: 'Click to view the release notes')
    @attach() if previousVersion? and previousVersion isnt atom.getVersion()

  attach: ->
    @statusBar.addRightTile(item: this, priority: -100)

  detached: ->
    @subscriptions?.dispose()
