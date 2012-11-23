#mocha
e = require 'expect.js', false
describe 'Event Pipe Test', ->
  ep = require '../lib/event-pipe'
  describe 'Sequence Test', ->
    flag = 0;
    it 'sync', ->
      ee = ep()
      ee.add ->
        e(flag++).to.be 0
        @a = 0;
        @(1, 2)
      , (a1, a2) ->
        e(@a).to.be 0
        e(a1).to.be 1
        e(a2).to.be 2
        e(flag++).to.be 1
        @()
      .on 'drain', (self)->
        e(self.a).to.be 0
        e(flag).to.be 2
      .run()

    it 'async', (done) ->
      flag = 0;
      ep ->
        process.nextTick (->
          @.a = 0;
          e(flag++).to.be 0
          @(1, 2)
        ).bind(@)
      , (a1, a2) ->
        process.nextTick (->
          e(@.a++).to.be 0
          e(a1).to.be 1
          e(a2).to.be 2
          e(flag++).to.be 1
          @(3,4)
        ).bind(@)
      , (a1, a2) ->
        process.nextTick (->
          e(@.a++).to.be 1
          e(a1).to.be 3
          e(a2).to.be 4
          e(flag++).to.be 2
          done()
        ).bind(@)
      .run()
    it 'mixed', (done) ->
      flag = 0;
      ep ->
        e(flag++).to.be 0
        @.a = 0;
        @(1, 2)
      , (a1, a2) ->
        process.nextTick (->
          e(@.a++).to.be 0
          e(a1).to.be 1
          e(a2).to.be 2
          e(flag++).to.be 1
          @(3,4)
        ).bind(@)
      , (a1, a2) ->
        e(@.a++).to.be 1
        e(a1).to.be 3
        e(a2).to.be 4
        e(flag++).to.be 2
        done()
      .run()
  describe 'Parallel Test', ->
    it 'prepend', (done) ->
      flag = 0
      par = ->
        e(flag++).to.within 0,1
        @()
      ep [par, par], ->
        e(flag).to.be 2
        done()
      .run()
    it 'append', (done) ->
      flag = 0
      par = (a) ->
        e(a).to.be 'start'
        e(flag++).to.within 0,1
        @()
      ep ->
        @('start')
      , [par, par], ->
        e(flag).to.be 2
        done()
      .run()
    it 'stop', (done) ->
      flag = 0
      stop = false
      ep ->
        process.nextTick (->
          flag++
          @()
        ).bind @
      , ->
        process.nextTick (->
          flag++
          @()
        ).bind @
      .run()
      .on 'stopped', ->
        stop = true
      .stop()
      setTimeout ->
        e(flag).to.be 1
        e(stop).to.be true
        done()
      , 10
    it 'stop2', (done) ->
      flag = 0
      stop = false
      ep ->
        @__stop()
        process.nextTick (->
          flag++
          @()
        ).bind @
      , ->
        process.nextTick (->
          flag++
          @()
        ).bind @
      .run()
      .on 'stopped', ->
        stop = true
      setTimeout ->
        e(flag).to.be 1
        e(stop).to.be true
        done()
      , 10


