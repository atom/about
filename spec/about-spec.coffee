shell = require 'shell'
About = require '../lib/about'
{$} = require 'atom-space-pen-views'

describe "About", ->
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)

    waitsForPromise ->
      atom.packages.activatePackage('about')

  describe "when the about:about-atom command is triggered", ->
    it "shows the About Atom view", ->
      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.about')).not.toExist()
      atom.workspace.open('atom://about')

      waitsFor ->
        atom.workspace.getActivePaneItem()

      runs ->
        aboutElement = workspaceElement.querySelector('.about')
        expect(aboutElement).toBeVisible()

  describe "when the version number is clicked", ->
    it "copies the version number to the clipboard", ->
      atom.workspace.open('atom://about')

      waitsFor ->
        atom.workspace.getActivePaneItem()

      runs ->
        aboutElement = workspaceElement.querySelector('.about')
        versionContainer = aboutElement.querySelector('.about-version-container')
        $(versionContainer).click()
        expect(atom.clipboard.read()).toBe atom.getVersion()

  describe "updates", ->
    [aboutElement, updateModel] = []

    beforeEach ->
      jasmine.attachToDOM(workspaceElement)
      atom.workspace.open('atom://about')
      waitsFor ->
        atom.workspace.getActivePaneItem()
      runs ->
        aboutElement = workspaceElement.querySelector('.about')
        updateModel = $(aboutElement).view().updateManager

    describe "when the updates are not supported by the platform", ->
      it "hides the auto update UI", ->
        spyOn(atom.autoUpdater, 'platformSupportsUpdates').andReturn(false)
        updateModel.resetState()
        expect(aboutElement.querySelector('.about-updates')).not.toBeVisible()

    describe "when updates are supported by the platform", ->
      beforeEach ->
        spyOn(atom.autoUpdater, 'platformSupportsUpdates').andReturn(true)
        updateModel.resetState()

      it "shows the auto update UI", ->
        expect(aboutElement.querySelector('.about-updates')).toBeVisible()

      it "shows the correct panels when the app checks for updates and there is no update available", ->
        expect(aboutElement.querySelector('.about-default-update-message')).toBeVisible()

        MockUpdater.checkForUpdate()
        expect(aboutElement.querySelector('.app-up-to-date')).not.toBeVisible()
        expect(aboutElement.querySelector('.app-checking-for-updates')).toBeVisible()

        MockUpdater.updateNotAvailable()
        expect(aboutElement.querySelector('.app-up-to-date')).toBeVisible()
        expect(aboutElement.querySelector('.app-checking-for-updates')).not.toBeVisible()

      it "shows the correct panels and button states when the app checks for updates and an update is downloaded", ->
        expect(aboutElement.querySelector('.about-default-update-message')).toBeVisible()
        expect(aboutElement.querySelector('.about-update-action-button').disabled).toBe false
        expect(aboutElement.querySelector('.about-update-action-button').textContent).toBe 'Check for update'

        MockUpdater.checkForUpdate()
        expect(aboutElement.querySelector('.app-up-to-date')).not.toBeVisible()
        expect(aboutElement.querySelector('.app-checking-for-updates')).toBeVisible()
        expect(aboutElement.querySelector('.about-update-action-button').disabled).toBe true
        expect(aboutElement.querySelector('.about-update-action-button').textContent).toBe 'Check for update'

        MockUpdater.downloadUpdate()
        expect(aboutElement.querySelector('.app-checking-for-updates')).not.toBeVisible()
        expect(aboutElement.querySelector('.app-downloading-update')).toBeVisible()
        # TODO: at some point it would be nice to be able to cancel an update download, and then this would be a cancel button
        expect(aboutElement.querySelector('.about-update-action-button').disabled).toBe true
        expect(aboutElement.querySelector('.about-update-action-button').textContent).toBe 'Check for update'

        MockUpdater.finishDownloadingUpdate(42)
        expect(aboutElement.querySelector('.app-downloading-update')).not.toBeVisible()
        expect(aboutElement.querySelector('.app-update-available-to-install')).toBeVisible()
        expect(aboutElement.querySelector('.app-update-available-to-install .about-updates-version').textContent).toBe('42')
        expect(aboutElement.querySelector('.about-update-action-button').disabled).toBe false
        expect(aboutElement.querySelector('.about-update-action-button').textContent).toBe 'Restart and install'

      it "opens the release notes for the downloaded release when the release notes link are clicked", ->
        shell = require('shell')
        MockUpdater.finishDownloadingUpdate('1.2.3')

        spyOn(shell, 'openExternal')
        link = aboutElement.querySelector('.app-update-available-to-install .about-updates-release-notes')
        link.click()

        args = shell.openExternal.mostRecentCall.args
        expect(shell.openExternal).toHaveBeenCalled()
        expect(args[0]).toContain '/v1.2.3'

      it "executes checkForUpdate() when the check for update button is clicked", ->
        spyOn(atom.autoUpdater, 'checkForUpdate')
        button = aboutElement.querySelector('.about-update-action-button')
        button.click()
        expect(atom.autoUpdater.checkForUpdate).toHaveBeenCalled()

      it "executes restartAndInstallUpdate() when the restart and install button is clicked", ->
        spyOn(atom.autoUpdater, 'restartAndInstallUpdate')
        MockUpdater.finishDownloadingUpdate(42)
        button = aboutElement.querySelector('.about-update-action-button')
        button.click()
        expect(atom.autoUpdater.restartAndInstallUpdate).toHaveBeenCalled()

      describe "when core.automaticallyUpdate is toggled", ->
        beforeEach ->
          atom.config.set('core.automaticallyUpdate', true)

        it "shows the auto update UI", ->
          expect(aboutElement.querySelector('.about-auto-updates input').checked).toBe true
          expect(aboutElement.querySelector('.about-default-update-message .about-default-enabled-update-message')).toBeVisible()
          expect(aboutElement.querySelector('.about-default-update-message .about-default-disabled-update-message')).not.toBeVisible()

          atom.config.set('core.automaticallyUpdate', false)
          expect(aboutElement.querySelector('.about-auto-updates input').checked).toBe false
          expect(aboutElement.querySelector('.about-default-update-message .about-default-enabled-update-message')).not.toBeVisible()
          expect(aboutElement.querySelector('.about-default-update-message .about-default-disabled-update-message')).toBeVisible()

        it "updates config and the UI when the checkbox is used to toggle", ->
          expect(aboutElement.querySelector('.about-auto-updates input').checked).toBe true

          $(aboutElement.querySelector('.about-auto-updates input')).click()
          expect(atom.config.get('core.automaticallyUpdate')).toBe false
          expect(aboutElement.querySelector('.about-auto-updates input').checked).toBe false
          expect(aboutElement.querySelector('.about-default-update-message .about-default-enabled-update-message')).not.toBeVisible()
          expect(aboutElement.querySelector('.about-default-update-message .about-default-disabled-update-message')).toBeVisible()

          $(aboutElement.querySelector('.about-auto-updates input')).click()
          expect(atom.config.get('core.automaticallyUpdate')).toBe true
          expect(aboutElement.querySelector('.about-auto-updates input').checked).toBe true
          expect(aboutElement.querySelector('.about-default-update-message .about-default-enabled-update-message')).toBeVisible()
          expect(aboutElement.querySelector('.about-default-update-message .about-default-disabled-update-message')).not.toBeVisible()

describe "the status bar", ->
  workspaceElement = null

  beforeEach ->
    storage = {}
    spyOn(localStorage, 'setItem').andCallFake (key, value) -> storage[key] = value
    spyOn(localStorage, 'getItem').andCallFake (key) -> storage[key]

    spyOn(atom, 'isReleasedVersion').andReturn(true)

    workspaceElement = atom.views.getView(atom.workspace)

    waitsForPromise ->
      atom.packages.activatePackage('status-bar')

    waitsForPromise ->
      atom.packages.activatePackage('about')

    waitsForPromise ->
      atom.workspace.open('sample.js')

  afterEach ->
    atom.packages.deactivatePackage('about')
    atom.packages.deactivatePackage('status-bar')

  describe "with no update", ->
    it "does not show the view", ->
      expect(workspaceElement).not.toContain('.about-release-notes')

  describe "with an update", ->
    it "shows the view when the update is made available", ->
      triggerUpdate('42')
      expect(workspaceElement).toContain('.about-release-notes')

    describe "clicking on the status", ->
      it "opens the release notes", ->
        triggerUpdate('42')
        expect(workspaceElement).toContain('.about-release-notes')

        releaseNotesCall = spyOn(shell, 'openExternal')
        $(workspaceElement).find('.about-release-notes').trigger('click')
        expect(releaseNotesCall.mostRecentCall.args[0]).toBe 'https://atom.io/releases'

    it "continues to show the squirrel until Atom is updated to the new version", ->
      triggerUpdate('42')
      expect(workspaceElement).toContain('.about-release-notes')

      runs ->
        atom.packages.deactivatePackage('about')
        expect(workspaceElement).not.toContain('.about-release-notes')

      waitsForPromise -> atom.packages.activatePackage('about')
      waits(1) # Service consumption hooks are deferred until the next tick
      runs -> expect(workspaceElement).toContain('.about-release-notes')

      runs ->
        atom.packages.deactivatePackage('about')
        expect(workspaceElement).not.toContain('.about-release-notes')

      runs ->
        spyOn(atom, 'getVersion').andReturn('42')

      waitsForPromise -> atom.packages.activatePackage('about')
      waits(1) # Service consumption hooks are deferred until the next tick
      runs -> expect(workspaceElement).not.toContain('.about-release-notes')

triggerUpdate = (version) ->
  atom.updateAvailable({releaseVersion: version})

MockUpdater =
  checkForUpdate: ->
    atom.autoUpdater.emitter.emit('did-begin-checking-for-update')

  updateNotAvailable: ->
    atom.autoUpdater.emitter.emit('update-not-available')

  downloadUpdate: ->
    atom.autoUpdater.emitter.emit('did-begin-downloading-update')

  finishDownloadingUpdate: (releaseVersion) ->
    version = {releaseVersion}
    atom.autoUpdater.emitter.emit('did-complete-downloading-update', version)
    atom.updateAvailable(version)
