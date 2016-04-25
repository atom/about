/** @babel */

import {View} from 'atom-space-pen-views'
import {CompositeDisposable} from 'atom'

export default class AboutStatusBar extends View {
  static content () {
    return this.span({type: 'button', class: 'about-release-notes icon icon-squirrel inline-block'})
  }

  constructor () {
    super()

    this.subscriptions = new CompositeDisposable()

    this.on('click', () => {
      atom.workspace.open('atom://about')
    })

    this.subscriptions.add(atom.tooltips.add(this.element, {title: 'An update will be installed the next time Atom is relaunched.<br/><br/>Click for more information.'}))
  }

  detached () {
    this.subscriptions.dispose()
  }
}
