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

triggerUpdate = ->
  atom.commands.dispatch(atom.views.getView(atom.workspace), 'window:update-available', ['v22.0.0'])

describe "the status bar", ->
  workspaceElement = null

  beforeEach ->
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
      triggerUpdate()
      expect(workspaceElement).toContain('.about-release-notes')

    describe "clicking on the status", ->
      it "opens the release notes", ->
        triggerUpdate()
        expect(workspaceElement).toContain('.about-release-notes')

        releaseNotesCall = spyOn(shell, 'openExternal')
        $(workspaceElement).find('.about-release-notes').trigger('click')
        expect(releaseNotesCall.mostRecentCall.args[0]).toBe 'https://atom.io/releases'
