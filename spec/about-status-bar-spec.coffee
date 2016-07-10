$ = require('jquery')
Updater = require('./mocks/updater')

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
      Updater.triggerUpdate('42')
      expect(workspaceElement).toContain('.about-release-notes')

    describe "clicking on the status", ->
      it "opens the about page", ->
        Updater.triggerUpdate('42')
        $(workspaceElement).find('.about-release-notes').trigger('click')

        waitsFor ->
          workspaceElement.querySelector('.about')
        runs ->
          expect(workspaceElement.querySelector('.about')).toExist()

    it "continues to show the squirrel until Atom is updated to the new version", ->
      Updater.triggerUpdate('42')
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
