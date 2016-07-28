/** @babel */
/** @jsx etch.dom */

import {Emitter} from 'atom'
import etch from 'etch'

/*
  Public: Abstract class for handling the initialization
  boilerplate of an Etch component.
*/
export default class EtchComponent {
  constructor (props) {
    this.props = props

    etch.initialize(this)
    EtchComponent.setScheduler(atom.views)

    this.emitter = new Emitter()
    this.emitter.emit('component-did-mount')
  }

  /*
    Public: Gets the scheduler Etch uses for coordinating DOM updates.

    Returns a {Scheduler}
  */
  static getScheduler () {
    return etch.getScheduler()
  }

  /*
    Public: Sets the scheduler Etch uses for coordinating DOM updates.

    * `scheduler` {Scheduler}
  */
  static setScheduler (scheduler) {
    etch.setScheduler(scheduler)
  }

  /*
    Public: Add a listener for when the component is initialized and
    rendered in the DOM.

    * `callback` {Function} to call when the component has been mounted in the
      DOM
  */
  componentDidMount (callback) {
    this.emitter.on('component-did-mount', callback)
  }

  /*
    Public: Updates the component's properties and re-renders it. Only the
    properties you specify in this object will update – any other properties
    the component stores will be unaffected.

    * `props` an {Object} representing the properties you want to update
  */
  update (props) {
    let oldProps = this.props
    this.props = Object.assign({}, oldProps, props)
    return etch.update(this)
  }

  /*
    Public: Destroys the component, cleaning up all references and event
    listeners.
  */
  destroy () {
    etch.destroy(this)
  }

  render () {
    throw new Error('Etch components must implement a `render` method')
  }
}
