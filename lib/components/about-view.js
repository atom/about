const {Disposable} = require('atom')
const etch = require('etch')
const shell = require('shell')
const AtomLogo = require('./atom-logo')
const EtchComponent = require('../etch-component')
const UpdateView = require('./update-view')

const $ = etch.dom

module.exports =
class AboutView extends EtchComponent {
  handleVersionClick (e) {
    e.preventDefault()
    atom.clipboard.write(this.props.currentVersion)
  }

  handleReleaseNotesClick (e) {
    e.preventDefault()
    shell.openExternal(this.props.updateManager.getReleaseNotesURLForAvailableVersion())
  }

  handleLicenseClick (e) {
    e.preventDefault()
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'application:open-license')
  }

  handleTermsOfUseClick (e) {
    e.preventDefault()
    shell.openExternal('https://atom.io/terms')
  }

  handleHowToUpdateClick (e) {
    e.preventDefault()
    shell.openExternal('https://flight-manual.atom.io/getting-started/sections/installing-atom/')
  }

  render () {
    return $.div({className: 'pane-item native-key-bindings about'},
      $.div({className: 'about-container'},
        $.header({className: 'about-header'},
          $.a({className: 'about-atom-io', href: 'https://atom.io'},
            $(AtomLogo)
          ),
          $.div({className: 'about-header-info'},
            $.span({className: 'about-version-container inline-block', onclick: this.handleVersionClick.bind(this)},
              $.span({className: 'about-version'}, `${this.props.currentVersion} ${process.arch}`),
              $.span({className: 'icon icon-clippy about-copy-version'})
            ),
            $.a({className: 'about-header-release-notes', onclick: this.handleReleaseNotesClick.bind(this)}, 'Release Notes')
          )
        ),

        $(UpdateView, {
          updateManager: this.props.updateManager,
          availableVersion: this.props.availableVersion,
          viewUpdateReleaseNotes: this.handleReleaseNotesClick.bind(this),
          viewUpdateInstructions: this.handleHowToUpdateClick.bind(this)
        }),

        $.div({className: 'about-actions group-item'},
          $.div({className: 'btn-group'},
            $.button({className: 'btn view-license', onclick: this.handleLicenseClick.bind(this)}, 'License'),
            $.button({className: 'btn terms-of-use', onclick: this.handleTermsOfUseClick.bind(this)}, 'Terms of Use')
          )
        ),

        $.div({className: 'about-love group-start'},
          $.span({className: 'icon icon-code'}),
          $.span({className: 'inline'}, ' with '),
          $.span({className: 'icon icon-heart'}),
          $.span({className: 'inline'}, ' by '),
          $.a({className: 'icon icon-logo-github', href: 'https://github.com'})
        ),

        $.div({className: 'about-credits group-item'},
          $.span({className: 'inline'}, 'And the awesome '),
          $.a({href: 'https://github.com/atom/atom/contributors'}, 'Atom Community')
        )
      )
    )
  }

  serialize () {
    return {
      deserializer: this.constructor.name,
      uri: this.props.uri
    }
  }

  onDidChangeTitle () {
    return new Disposable()
  }

  onDidChangeModified () {
    return new Disposable()
  }

  getTitle () {
    return 'About'
  }

  getIconName () {
    return 'info'
  }
}
