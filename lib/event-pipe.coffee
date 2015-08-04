{EventEmitter} = require "events"
{isArray, isFunction} = require 'util'

class EventPipe extends EventEmitter
  constructor: (cbs...) ->
    @list = []
    @_setContainer()
    @reset()
    @add cbs... if cbs.length

  _setContainer: ->
    @container = (args...) =>
      if @stopped
        @emit 'stopped', @container
        return

      if @pointer >= @list.length
        @emit 'drain', @container
        return

      [type, cbs, lazy] = @list[@pointer]

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

      switch type
        # seq to next cb
        when 'seq' then cbs.apply @container, args
        # par to next cbs
        when 'par'
          @flag = cbs.length
          cb.apply @container, args for cb in cbs

    @container.stop = =>
      @stop()
      
    @container

  add: (cbs...) ->
    for cb in cbs
      if isFunction cb
        @seq cb
      else if isArray cb
        @par cb...
    this
  lazy: (cbs...) ->
    for cb in cbs
      if isFunction cb
        @lseq cb
      else if isArray cb
        @lpar cb...
    this
  seq: (cbs...) ->
    @list.push ['seq', cb] for cb in cbs
    this
  lseq: (cbs...) ->
    @list.push ['seq', cb, yes] for cb in cbs
    this
  par: (cbs...) ->
    @list.push ['par', cbs]
    this
  lpar: (cbs...) ->
    @list.push ['par', cbs, yes]
    this
  run: (args...) ->
    @container args...
    this
  stop: ->
    @stopped = yes
    @emit 'stop'
    this
  reset: ->
    @flag = @pointer = 0
    @parArgs = []
    this

module.exports = (args...) ->
  new EventPipe args...
