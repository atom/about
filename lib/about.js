/** @babel */

import {CompositeDisposable, Emitter} from 'atom'

// Deferred requires
let shell
let AboutView
let UpdateManager

export default class About {
  constructor (initialState) {
    this.subscriptions = new CompositeDisposable()
    this.emitter = new Emitter()

    this.state = initialState
    this.views = {
      aboutView: null
    }

    this.subscriptions.add(atom.workspace.addOpener((uriToOpen) => {
      if (uriToOpen === this.state.uri) {
        return this.deserialize()
      }
    }))

    this.subscriptions.add(atom.commands.add('atom-workspace', 'about:view-release-notes', () => {
      shell = shell || require('electron').shell
      shell.openExternal(this.getUpdateManager().getReleaseNotesURLForCurrentVersion())
    }))
  }

  destroy () {
    if (this.views.aboutView) this.views.aboutView.destroy()
    this.views.aboutView = null

    if (this.state.updateManager) this.state.updateManager.dispose()
    this.setState({updateManager: null})

    this.subscriptions.dispose()
  }

  setState (newState) {
    if (newState && typeof newState === 'object') {
      let {state} = this
      this.state = Object.assign({}, state, newState)

      this.didChange()
    }
  }

  didChange () {
    this.emitter.emit('did-change')
  }

  onDidChange (callback) {
    this.emitter.on('did-change', callback)
  }

  getUpdateManager () {
    UpdateManager = UpdateManager || require('./update-manager')

    if (!this.state.updateManager) {
      this.setState({
        updateManager: new UpdateManager()
      })
    }

    return this.state.updateManager
  }

  deserialize (state) {
    if (!this.views.aboutView) {
      AboutView = AboutView || require('./components/about-view')

      this.setState(state)

      this.views.aboutView = new AboutView({
        uri: this.state.uri,
        updateManager: this.getUpdateManager(),
        currentVersion: this.state.currentVersion,
        availableVersion: this.state.updateManager.getAvailableVersion()
      })
      this.handleStateChanges()
    }

    return this.views.aboutView
  }

  handleStateChanges () {
    this.onDidChange(() => {
      if (this.views.aboutView) {
        this.views.aboutView.update({
          updateManager: this.state.updateManager,
          currentVersion: this.state.currentVersion,
          availableVersion: this.state.updateManager.getAvailableVersion()
        })
      }
    })

    this.state.updateManager.onDidChange(() => {
      this.didChange()
    })
  }
}
