events = require "events"

class EventPipe extends events.EventEmitter
  constructor: (cbs...) ->
    @list = []
    @pointer = 0
    @flag = 0
    @container = ((args...) ->
      if @stopped
        @emit 'stopped', @container
        return
      if @pointer >= @list.length
        @emit 'drain', @container
        return
      return if --@flag > 0
      [type, cb] = @list[@pointer]
      @pointer++
      if type is 'seq'
        cb.apply @container, args
      else if type is 'par'
        @flag = cb.length;
        cb1.apply @container, args for cb1 in cb
      return
    ).bind @
    @container.__stop = =>
      @stop()

    return if cbs.length is 0
    @add cbs...
    # @run()
  add: (cbs...) ->
    for cb in cbs
      if typeof cb is 'function'
        @seq cb
      else if typeof cb is 'object' and cb instanceof Array
        @par cb...
    @
  seq: (cbs...) ->
    @list.push ['seq', cb] for cb in cbs
    @
  par: (cbs...) ->
    @list.push ['par', cbs]
    @
  run: (args...) ->
    @container(args...)
    @
  stop: ->
    @stopped = true
    @emit 'stop'
    @

module.exports = (args...) ->
  new EventPipe args...


