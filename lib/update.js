'use babel'

import {Emitter} from 'atom'

Unsupported = 'unsupported'
Default = 'default'
CheckingForUpdate = 'checking-for-update'
DownloadingUpdate = 'downloading-update'
UpdateAvailableToInstall = 'update-avialable-to-install'
UpToDate = 'up-to-date'

export default class Update {
  constructor () {
    this.emitter = new Emitter
    this.currentVersion = atom.getVersion()
    this.availableVersion = atom.getVersion()
    this.resetState()
    this.listenForAtomEvents()
  }

  listenForAtomEvents () {
    atom.autoUpdater.onDidBeginCheckingForUpdate(() => {
      this.setState(CheckingForUpdate)
    })

    atom.autoUpdater.onDidBeginDownloadingUpdate(() => {
      this.setState(DownloadingUpdate)
    })

    atom.autoUpdater.onDidCompleteDownloadingUpdate((detail) => {
      let {releaseName, releaseVersion} = detail
      this.setAvailableVersion(releaseVersion)
    })

    atom.autoUpdater.onUpdateNotAvailable(() => {
      this.setState(UpToDate)
    })

    atom.config.observe('core.automaticallyUpdate', (value) => {
      this.autoUpdatesEnabled = value
      this.emitDidChange()
    })

    // TODO: When https://github.com/atom/electron/issues/4587 is closed we can add this support.
    // atom.autoUpdater.onUpdateAvailable =>
    //   @find('.about-updates-item').removeClass('is-shown')
    //   @updateAvailable.addClass('is-shown')
  }

  onDidChange (callback) {
    return this.emitter.on('did-change', callback)
  }

  emitDidChange () {
    this.emitter.emit('did-change')
  }

  getAutoUpdatesEnabled () {
    return this.autoUpdatesEnabled
  }

  setAutoUpdatesEnabled (enabled) {
    return atom.config.set('core.automaticallyUpdate', enabled)
  }

  getState () {
    return this.state
  }

  setState (state) {
    this.state = state
    this.emitDidChange()
  }

  resetState () {
    this.state = atom.autoUpdater.platformSupportsUpdates() ? Default : Unsupported
    this.emitDidChange()
  }

  getAvailableVersion () {
    return this.availableVersion
  }

  setAvailableVersion (version) {
    this.availableVersion = version

    if (this.availableVersion !== this.currentVersion) {
      this.state = UpdateAvailableToInstall
    } else {
      this.state = UpToDate
    }

    this.emitDidChange()
  }

  checkForUpdate () {
    atom.autoUpdater.checkForUpdate()
  }

  restartAndInstallUpdate () {
    atom.autoUpdater.restartAndInstallUpdate()
  }

  getReleaseNotesURLForCurrentVersion () {
    return this.getReleaseNotesURLForVersion(this.currentVersion)
  }

  getReleaseNotesURLForAvailableVersion () {
    return this.getReleaseNotesURLForVersion(this.availableVersion)
  }

  getReleaseNotesURLForVersion (appVersion) {
    if (!appVersion.startsWith('v'))
      appVersion = `v${appVersion}`
    return `https://github.com/atom/atom/releases/tag/${appVersion}`
  }
}

Update.State = {
  Unsupported: Unsupported,
  Default: Default,
  CheckingForUpdate: CheckingForUpdate,
  DownloadingUpdate: DownloadingUpdate,
  UpdateAvailableToInstall: UpdateAvailableToInstall,
  UpToDate: UpToDate,
}
