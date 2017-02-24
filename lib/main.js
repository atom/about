/** @babel */

import {CompositeDisposable} from 'atom'

let About
let StatusBarView

// The local storage key for the available update version.
const AvailableUpdateVersion = 'about:version-available'
const AboutURI = 'atom://about'

export default {
  activate () {
    this.subscriptions = new CompositeDisposable()

    About = About || require('./about')
    this.model = new About({
      uri: AboutURI,
      currentVersion: atom.getVersion()
    })

    let availableVersion = window.localStorage.getItem(AvailableUpdateVersion)
    if (availableVersion === atom.getVersion()) {
      window.localStorage.removeItem(AvailableUpdateVersion)
    }

    this.subscriptions.add(atom.autoUpdater.onDidCompleteDownloadingUpdate(({releaseVersion}) => {
      window.localStorage.setItem(AvailableUpdateVersion, releaseVersion)
      this.showStatusBarIfNeeded()
    }))
  },

  deactivate () {
    this.model.destroy()
    if (this.statusBarTile) this.statusBarTile.destroy()
  },

  consumeStatusBar (statusBar) {
    this.statusBar = statusBar
    this.showStatusBarIfNeeded()
  },

  deserializeAboutView (state) {
    if (!this.model) {
      About = About || require('./about')
      this.model = new About({
        uri: AboutURI,
        currentVersion: atom.getVersion()
      })
    }

    return this.model.deserialize(state)
  },

  isUpdateAvailable () {
    let availableVersion = window.localStorage.getItem(AvailableUpdateVersion)
    return availableVersion && availableVersion !== atom.getVersion()
  },

  showStatusBarIfNeeded () {
    if (this.isUpdateAvailable() && this.statusBar) {
      StatusBarView = StatusBarView || require('./components/about-status-bar')

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
