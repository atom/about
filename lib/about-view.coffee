{ScrollView} = require 'atom-space-pen-views'
{Disposable} = require 'atom'

module.exports =
class AboutView extends ScrollView
  @content: ->
    @div class: 'pane-item native-key-bindings about-atom', tabindex: -1, =>
      @div class: 'panel', =>
        @header class: 'atom-header', =>
          @img class: 'atom-icon', src: 'atom://about/assets/atom.png'
          @div class: 'inline-block', =>
            @div class: 'atom-heading', 'Atom'
            @span class: 'atom-version', outlet: 'atomVersion'
            @button outlet: 'copyAtomVersion', class: 'btn icon icon-clippy'
        @div class: 'credits', outlet: 'credits', =>
          @span class: 'icon icon-code'
          @span class: 'inline', ' with '
          @span class: 'icon icon-heart'
          @span class: 'inline', ' by '
          @a class: 'icon icon-logo-github', href: 'https://github.com'
          @span class: 'inline', ' and the '
          @a href: 'https://github.com/atom/atom/contributors', 'Atom Community'

  onDidChangeTitle: -> new Disposable ->
  onDidChangeModified: -> new Disposable ->

  initialize: ({@uri}) ->
    @atomVersion.text(atom.getVersion())

    @copyAtomVersion.on 'click', =>
      atom.clipboard.write(@atomVersion.text())


  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()

  getURI: -> @uri

  getTitle: -> 'About'

  getIconName: -> 'info'
