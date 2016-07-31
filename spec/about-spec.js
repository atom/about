/** @babel */

describe('About', () => {
  let workspaceElement

  beforeEach(() => {
    workspaceElement = atom.views.getView(atom.workspace)

    waitsForPromise(() => {
      return atom.packages.activatePackage('about')
    })
  })

  it('deserializes correctly', () => {
    let deserializedAboutView = atom.deserializers.deserialize({
      deserializer: 'AboutView',
      uri: 'atom://about'
    })

    expect(deserializedAboutView).toBeTruthy()
  })

  describe('when the about:about-atom command is triggered', () => {
    it('shows the About Atom view', () => {
      // Attaching the workspaceElement to the DOM is required to allow the
      // `toBeVisible()` matchers to work. Anything testing visibility or focus
      // requires that the workspaceElement is on the DOM. Tests that attach the
      // workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.about')).not.toExist()
      atom.workspace.open('atom://about')

      waitsFor(() => {
        return atom.workspace.getActivePaneItem()
      })

      runs(() => {
        let aboutElement = workspaceElement.querySelector('.about')
        expect(aboutElement).toBeVisible()
      })
    })
  })

  describe('when the version number is clicked', () => {
    it('copies the version number to the clipboard', () => {
      atom.workspace.open('atom://about')

      waitsFor(() => {
        return atom.workspace.getActivePaneItem()
      })

      runs(() => {
        let aboutElement = workspaceElement.querySelector('.about')
        let versionContainer = aboutElement.querySelector('.about-version-container')
        versionContainer.click()
        expect(atom.clipboard.read()).toBe(atom.getVersion())
      })
    })
  })
})
