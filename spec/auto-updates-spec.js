'use babel'

// Specs for the auto-update settings and info shown on the about page.

import About from 'lib/about'

describe('Auto-updates', () => {
  let workspaceElement
  beforeEach(() => {
    workspaceElement = atom.views.getView(atom.workspace)
  })

  waitsForPromise(() => {
    atom.packages.activatePackage('about')
  })

  describe('when the About package is shown', () => {
    it('checks for available updates', () => {

    })
  })

  describe('when an update is available', () => {
    describe('when auto-update is enabled', () => {

    })

    describe('when auto-update is disabled', () => {

    })
  })

  describe('when Atom is up-to-date', () => {
    describe('when auto-update is enabled', () => {

    })

    describe('when auto-update is disabled', () => {

    })
  })
})
