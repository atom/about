/** @babel */

import {CompositeDisposable} from 'atom'

let AboutView = null
let StatusBarView = null
let UpdateManager = null
let updateManager = null

// The local storage key for the available update version.
const AvailableUpdateVersion = 'about:version-available'
const AboutURI = 'atom://about'

function getUpdateManager () {
  if (!updateManager) {
    UpdateManager = UpdateManager || require('./update-manager')
    updateManager = new UpdateManager()
  }

  return updateManager
}

export default {
  activate () {
    this.subscriptions = new CompositeDisposable()
    this.updateAvailable = false
    this.aboutView = null
    this.statusBarTile = null

    this.subscriptions.add(atom.workspace.addOpener((uriToOpen) => {
      if (uriToOpen === AboutURI) {
        return this.deserializeAboutView({uri: AboutURI})
      }
    }))

    this.subscriptions.add(atom.commands.add('atom-workspace', 'about:view-release-notes', () => {
      updateManager = getUpdateManager()
      const {shell} = require('electron')
      shell.openExternal(updateManager.getReleaseNotesURLForCurrentVersion())
    }))

    let availableVersion = window.localStorage.getItem(AvailableUpdateVersion)
    if (availableVersion === atom.getVersion()) {
      window.localStorage.removeItem(AvailableUpdateVersion)
    }

    if (atom.isReleasedVersion()) {
      this.subscriptions.add(atom.onUpdateAvailable(({releaseVersion}) => {
        window.localStorage.setItem(AvailableUpdateVersion, releaseVersion)
        this.showStatusBarIfNeeded()
      }))
    }
  },

  deactivate () {
    if (this.aboutView) this.aboutView.destroy()
    this.aboutView = null

    if (updateManager) updateManager.dispose()
    updateManager = null

    this.subscriptions.dispose()
    if (this.statusBarTile) this.statusBarTile.destroy()
  },

  consumeStatusBar (statusBar) {
    this.statusBar = statusBar
    this.showStatusBarIfNeeded()
  },

  deserializeAboutView (state) {
    if (!this.aboutView) {
      AboutView = AboutView || require('./about-view')
      this.updateManager = getUpdateManager()
      this.aboutView = new AboutView({
        uri: AboutURI,
        updateManager: this.updateManager,
        availableVersion: this.updateManager.getAvailableVersion()
      })

      updateManager.onDidChange(() => {
        this.aboutView.update({
          uri: AboutURI,
          updateManager: this.updateManager,
          availableVersion: this.updateManager.getAvailableVersion()
        })
      })
    }

    return this.aboutView
  },

  isUpdateAvailable () {
    let availableVersion = window.localStorage.getItem(AvailableUpdateVersion)
    return availableVersion && availableVersion !== atom.getVersion()
  },

  showStatusBarIfNeeded () {
    if (this.isUpdateAvailable() && this.statusBar) {
      StatusBarView = StatusBarView || require('./about-status-bar')

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
