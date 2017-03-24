const {CompositeDisposable} = require('atom')
const UpdateManager = require('./update-manager')
const About = require('./about')
const StatusBarView = require('./components/about-status-bar')
let updateManager

// The local storage key for the available update version.
const AvailableUpdateVersion = 'about:version-available'
const AboutURI = 'atom://about'

module.exports = {
  activate () {
    this.subscriptions = new CompositeDisposable()

    this.createModel()

    let availableVersion = window.localStorage.getItem(AvailableUpdateVersion)
    if (availableVersion === atom.getVersion()) {
      window.localStorage.removeItem(AvailableUpdateVersion)
    }

    this.subscriptions.add(updateManager.onDidChange(() => {
      if (updateManager.getState() === UpdateManager.State.UpdateAvailableToInstall) {
        window.localStorage.setItem(AvailableUpdateVersion, updateManager.getAvailableVersion())
        this.showStatusBarIfNeeded()
      }
    }))
  },

  deactivate () {
    this.model.destroy()
    if (this.statusBarTile) this.statusBarTile.destroy()

    if (updateManager) {
      updateManager.dispose()
      updateManager = undefined
    }
  },

  consumeStatusBar (statusBar) {
    this.statusBar = statusBar
    this.showStatusBarIfNeeded()
  },

  deserializeAboutView (state) {
    if (!this.model) {
      this.createModel()
    }

    return this.model.deserialize(state)
  },

  createModel () {
    updateManager = updateManager || new UpdateManager()

    this.model = new About({
      uri: AboutURI,
      currentVersion: atom.getVersion(),
      updateManager: updateManager
    })
  },

  isUpdateAvailable () {
    let availableVersion = window.localStorage.getItem(AvailableUpdateVersion)
    return availableVersion && availableVersion !== atom.getVersion()
  },

  showStatusBarIfNeeded () {
    if (this.isUpdateAvailable() && this.statusBar) {
      let statusBarView = new StatusBarView()

      if (this.statusBarTile) {
        this.statusBarTile.destroy()
      }

      this.statusBarTile = this.statusBar.addRightTile({
        item: statusBarView,
        priority: -100
      })

      return this.statusBarTile
    }
  }
}
