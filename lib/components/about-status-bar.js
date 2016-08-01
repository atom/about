/** @babel */
/** @jsx etch.dom */
/* eslint-disable react/no-unknown-property */

import {CompositeDisposable} from 'atom'
import etch from 'etch'
import EtchComponent from '../etch-component'

export default class AboutStatusBar extends EtchComponent {
  constructor () {
    super()
    this.subscriptions = new CompositeDisposable()

    this.subscriptions.add(atom.tooltips.add(this.element, {title: 'An update will be installed the next time Atom is relaunched.<br/><br/>Click the squirrel icon for more information.'}))
  }

  handleClick () {
    atom.workspace.open('atom://about')
  }

  render () {
    return (
      <span type='button' className='about-release-notes icon icon-squirrel inline-block' onclick={this.handleClick.bind(this)} />
    )
  }

  destroy () {
    super.destroy()
    this.subscriptions.dispose()
  }
}
