/** @babel */

import {it, fit, ffit, fffit, beforeEach, afterEach, conditionPromise} from './helpers/async-spec-helpers' // eslint-disable-line no-unused-vars
import MockUpdater from './mocks/updater'

describe('the status bar', () => {
  let workspaceElement

  beforeEach(async () => {
    let storage = {}

    spyOn(window.localStorage, 'setItem').andCallFake((key, value) => {
      storage[key] = value
    })
    spyOn(window.localStorage, 'getItem').andCallFake((key) => {
      return storage[key]
    })

    workspaceElement = atom.views.getView(atom.workspace)

    await atom.packages.activatePackage('status-bar')
    await atom.packages.activatePackage('about')
    await atom.workspace.open('sample.js')
  })

  afterEach(() => {
    atom.packages.deactivatePackage('about')
    atom.packages.deactivatePackage('status-bar')
  })

  describe('with no update', () => {
    it('does not show the view', () => {
      expect(workspaceElement).not.toContain('.about-release-notes')
    })
  })

  describe('with an update', () => {
    it('shows the view when the update finishes downloading', () => {
      MockUpdater.finishDownloadingUpdate('42')
      expect(workspaceElement).toContain('.about-release-notes')
    })

    describe('clicking on the status', () => {
      it('opens the about page', async () => {
        MockUpdater.finishDownloadingUpdate('42')
        workspaceElement.querySelector('.about-release-notes').click()
        await conditionPromise(() => workspaceElement.querySelector('.about'))
        expect(workspaceElement.querySelector('.about')).toExist()
      })
    })

    it('continues to show the squirrel until Atom is updated to the new version', async () => {
      MockUpdater.finishDownloadingUpdate('42')
      expect(workspaceElement).toContain('.about-release-notes')

      atom.packages.deactivatePackage('about')
      expect(workspaceElement).not.toContain('.about-release-notes')

      await atom.packages.activatePackage('about')
      await Promise.resolve() // Service consumption hooks are deferred until the next tick
      expect(workspaceElement).toContain('.about-release-notes')

      atom.packages.deactivatePackage('about')
      expect(workspaceElement).not.toContain('.about-release-notes')

      spyOn(atom, 'getVersion').andReturn('42')
      await atom.packages.activatePackage('about')

      await Promise.resolve() // Service consumption hooks are deferred until the next tick
      expect(workspaceElement).not.toContain('.about-release-notes')
    })
  })
})
