/** @babel */
/** @jsx etch.dom */

import etch from 'etch'

class UpdateView {
  constructor(props) {
    this.props = props
    etch.initialize(this)
  }

  update(props) {
    this.props = props
    return etch.update(this)
  }

  render() {
    return (
      <div className='about-updates group-start' ref='updatesContainer'>
        <div className='about-updates-box'>
          <div className='about-updates-status'>
            <div className='about-updates-item is-shown about-default-update-message' ref='defaultUpdateMessage'>
              <span className='about-updates-label about-default-enabled-update-message' ref='defaultEnabledUpdateMessage'>
                Atom will check for updates automatically
              </span>
              <span className='about-updates-label about-default-disabled-update-message' ref='defaultDisabledUpdateMessage'>
                Automatic updates are disabled please check manually
              </span>
            </div>

            <div className='about-updates-item app-up-to-date' ref='upToDate'>
              <span className='icon icon-check' />
              <span className='about-updates-label is-strong'>Atom is up to date!</span>
            </div>

            <div className='about-updates-item app-checking-for-updates' ref='checkingForUpdates'>
              <span className='about-updates-label icon icon-search'>Checking for updates...</span>
            </div>

            <div className='about-updates-item app-downloading-update' ref='downloadingUpdate'>
              <span className='loading loading-spinner-tiny inline-block' />
              <span className='about-updates-label'>Downloading update</span>
            </div>

            <div className='about-updates-item app-update-available-to-install' ref='updateAvailableToInstall'>
              <span className='about-updates-label icon icon-squirrel'>New update</span>
              <span className='about-updates-version' ref='updateAvailableVersion'>1.5.0</span>
              <a className='about-updates-release-notes' ref='viewUpdateReleaseNotes'>Release Notes</a>
            </div>

            <div className='about-updates-item app-update-error' ref='updateError'>
              <span className='icon icon-x' />
              <span className='about-updates-label app-error-message is-strong' ref='updateErrorMessage' />
            </div>
          </div>

          <button className='btn about-update-action-button' ref='updateActionButton'>{this.props.updateManager.state === 'update-available' ? 'Restart and install' : 'Check now'}</button>
        </div>


        <div className='about-auto-updates'>
          <label>
            <input type='checkbox' checked={true} ref='automaticallyUpdateCheckbox' />
            <span>Automatically download updates</span>
          </label>
        </div>

      </div>
    )
  }
}

export default UpdateView
