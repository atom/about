/** @babel */
/** @jsx etch.dom */

import {Emitter} from 'atom'
import etch from 'etch'

export default class EtchComponent {
  constructor (props) {
    this.props = props

    etch.initialize(this)
    this.setScheduler(atom.views)

    this.emitter = new Emitter()
    this.emitter.emit('component-did-mount')
  }

  componentDidMount (callback) {
    this.emitter.on('component-did-mount', callback)
  }

  setScheduler (scheduler) {
    etch.setScheduler(scheduler)
  }

  getScheduler () {
    return etch.getScheduler()
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

  // Must be implemented by subclass
  render () {
    return
  }
}
