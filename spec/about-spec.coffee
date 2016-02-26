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
        updateModel = $(aboutElement).view().update

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

      it "shows the correct panels when the app checks for updates and an update is downloaded", ->
        expect(aboutElement.querySelector('.about-default-update-message')).toBeVisible()

        MockUpdater.checkForUpdate()
        expect(aboutElement.querySelector('.app-up-to-date')).not.toBeVisible()
        expect(aboutElement.querySelector('.app-checking-for-updates')).toBeVisible()

        MockUpdater.downloadUpdate()
        expect(aboutElement.querySelector('.app-checking-for-updates')).not.toBeVisible()
        expect(aboutElement.querySelector('.app-downloading-update')).toBeVisible()

        MockUpdater.finishDownloadingUpdate(42)
        expect(aboutElement.querySelector('.app-downloading-update')).not.toBeVisible()
        expect(aboutElement.querySelector('.app-update-available-to-install')).toBeVisible()
        expect(aboutElement.querySelector('.app-update-available-to-install .about-updates-version').textContent).toBe('42')

      describe "when core.automaticallyUpdate is toggled", ->
        beforeEach ->
          atom.config.set('core.automaticallyUpdate', true)

        it "shows the auto update UI", ->
          expect(aboutElement.querySelector('.about-default-update-message .about-default-enabled-update-message')).toBeVisible()
          expect(aboutElement.querySelector('.about-default-update-message .about-default-disabled-update-message')).not.toBeVisible()

          atom.config.set('core.automaticallyUpdate', false)
          expect(aboutElement.querySelector('.about-default-update-message .about-default-enabled-update-message')).not.toBeVisible()
          expect(aboutElement.querySelector('.about-default-update-message .about-default-disabled-update-message')).toBeVisible()

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
