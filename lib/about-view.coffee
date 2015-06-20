{ScrollView} = require 'atom-space-pen-views'

module.exports =
class AboutView extends ScrollView
  @content: ->
    @div class: 'pane-item native-key-bindings about-atom', tabindex: -1, =>
      @img class: 'atom-icon', src: 'atom://about/assets/atom.png'
      @div class: 'atom-version', outlet: 'atomVersion'
      @button outlet: 'copyAtomVersion', class: 'btn icon icon-clippy'
      @div class: 'credits', outlet: 'credits', =>
        @span class: 'icon icon-code'
        @span class: 'inline', 'with'
        @span class: 'icon icon-heart'
        @span class: 'inline', 'by'
        @a class: 'icon icon-logo-github', href: 'https://github.com'

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
