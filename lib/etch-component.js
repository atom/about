/** @babel */
/** @jsx etch.dom */

import {Emitter} from 'atom'
import etch from 'etch'

export default class EtchComponent {
  constructor (props) {
    this.props = props

    etch.initialize(this)
    EtchComponent.setScheduler(atom.views)

    this.emitter = new Emitter()
    this.emitter.emit('component-did-mount')
  }

  static getScheduler () {
    return etch.getScheduler()
  }

  static setScheduler (scheduler) {
    etch.setScheduler(scheduler)
  }

  componentDidMount (callback) {
    this.emitter.on('component-did-mount', callback)
  }

  update (props) {
    let oldProps = this.props
    this.props = {
      ...oldProps,
      ...props
    }
    return etch.update(this)
  }

  destroy () {
    etch.destroy(this)
  }

  render () {
    throw new Error('Etch components must implement a `render` method')
  }
}
