/** @babel */

export default {
  updateError () {
    atom.autoUpdater.emitter.emit('update-error')
  },

  checkForUpdate () {
    atom.autoUpdater.emitter.emit('did-begin-checking-for-update')
  },

  updateNotAvailable () {
    atom.autoUpdater.emitter.emit('update-not-available')
  },

  downloadUpdate () {
    atom.autoUpdater.emitter.emit('did-begin-downloading-update')
  },

  finishDownloadingUpdate (releaseVersion) {
    let version = {releaseVersion}
    atom.autoUpdater.emitter.emit('did-complete-downloading-update', version)
    atom.updateAvailable(version)
  },

  triggerUpdate (releaseVersion) {
    atom.updateAvailable({releaseVersion})
  }
}
