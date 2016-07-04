/** @babel */
/** @jsx etch.dom */

import {CompositeDisposable} from 'atom'
import etch from 'etch'

export default class AboutStatusBar {
  constructor () {
    etch.initialize(this)
    this.subscriptions = new CompositeDisposable()

    // this.on('click', () => {
    //   atom.workspace.open('atom://about')
    // })

    this.subscriptions.add(atom.tooltips.add(this.element, {title: 'An update will be installed the next time Atom is relaunched.<br/><br/>Click the squirrel icon for more information.'}))
  }

  update () {
    etch.update(this)
  }

  render () {
    return <button className='about-release-notes icon icon-squirrel inline-block' />
  }
}
