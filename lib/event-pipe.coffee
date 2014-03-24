events = require "events"

isArray = (arg)->
  Object.prototype.toString.call(arg) is '[object Array]'

class EventPipe extends events.EventEmitter
  constructor: (cbs...) ->
    @list = []

    @reset()
    return if cbs.length is 0
    @add cbs...

  getContainer : ->
    container = (args...) =>
      if @stopped
        @emit 'stopped', @container
        return

      if @pointer >= @list.length
        @emit 'drain', @container
        return

      [type, cb, lazy] = @list[@pointer]

      # lazy mode
      if lazy
        [err, args...] = args
        if err
          @emit 'error', err
          @stop()
          return

      # parallel args
      @parArgs.push args if @flag-- > 0

      if @flag is 0 and @parArgs.length isnt 0
        args = @parArgs
        @parArgs = []

      # par not finished
      return if @flag > 0

      @pointer++

      # seq to next cb
      if type is 'seq'
        cb.apply @container, args
      # par to next cbs
      else if type is 'par'
        @flag = cb.length;
        cb1.apply @container, args for cb1 in cb
      return

    container.__stop = =>
      @stop()
    @container = container

  add: (cbs...) ->
    for cb in cbs
      if typeof cb is 'function'
        @seq cb
      else if isArray cb
        @par cb...
    @
  lazy: (cbs...) ->
    for cb in cbs
      if typeof cb is 'function'
        @lseq cb
      else if isArray cb
        @lpar cb...
    @
  seq: (cbs...) ->
    @list.push ['seq', cb] for cb in cbs
    @
  lseq: (cbs...) ->
    @list.push ['seq', cb, true] for cb in cbs
    @
  par: (cbs...) ->
    @list.push ['par', cbs]
    @
  lpar: (cbs...) ->
    @list.push ['par', cbs, true]
    @
  run: (args...) ->
    @container(args...)
    @
  stop: ->
    @stopped = true
    @emit 'stop'
    @
  reset : ->
    @flag = @pointer = 0
    @parArgs = []
    @getContainer()
    @

module.exports = (args...) ->
  new EventPipe args...

