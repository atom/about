'use babel'

import {Emitter} from 'atom'

CheckingForUpdate = 'checking-for-update'
DownloadingUpdate = 'downloading-update'
UpdateAvailableToInstall = 'update-avialable-to-install'
UpToDate = 'up-to-date'

export default class Update {
  constructor () {
    this.state = ''
    this.currentVersion = atom.getVersion()
    this.availableVersion = atom.getVersion()
    this.emitter = new Emitter
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

  getState () {
    return this.state
  }

  setState (state) {
    this.state = state
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
}

Update.State = {
  CheckingForUpdate: CheckingForUpdate,
  DownloadingUpdate: DownloadingUpdate,
  UpdateAvailableToInstall: UpdateAvailableToInstall,
  UpToDate: UpToDate,
}
