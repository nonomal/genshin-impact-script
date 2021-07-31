class TacticX

  isActive: false
  isPressed: {}

  constructor: ->

    player
      .on 'attack:start', @start
      .on 'attack:end', @stop

    party
      .on 'change', @reset
      .on 'switch', =>
        unless @isActive then return
        @stop()
        @start()

  attack: (isCharged, callback) ->

    if isCharged
      $.click 'left:down'
      @isPressed['l-button'] = true

      delay = 300
      name = party.name
      {weapon} = Character.data[name]
      switch weapon
        when 'bow'
          delay = 1500
          if name == 'ganyu'
            delay = 1800
          if name == 'tartaglia'
            delay = 300
        when 'sword'
          delay = 400
          if name == 'xingqiu'
            delay = 600

      @delay delay, =>
        $.click 'left:up'
        @isPressed['l-button'] = false

        if movement.isMoving and party.name == 'klee'
          @delay 200, => @jump callback
          return

        @delay 100, callback

      return

    $.click 'left'
    @delay 200, callback

  delay: (time, callback) ->
    unless @isActive then return
    $.clearTimeout timer.tacticDelay
    timer.tacticDelay = $.setTimeout callback, time

  execute: (listTactic, g = 0, i = 0) ->

    item = @get listTactic, g, i
    unless item
      @execute listTactic
      return
    # unless item == $.toLowerCase item
    #   item = "#{item}~"

    next = => @execute listTactic, g, i + 1

    map = {}

    map['!@e'] = => @ongoing next, =>
      @execute listTactic, g + 1, 0
    , 'not'
    map['!@m'] = => @onMoving next, =>
      @execute listTactic, g + 1, 0
    , 'not'
    map['@e'] = => @ongoing next, => @execute listTactic, g + 1, 0
    map['@m'] = => @onMoving next, => @execute listTactic, g + 1, 0

    map.a = => @attack false, next
    map['a~'] = => @attack true, next

    map.e = => @useE false, next
    map.ee = => @useE false, =>
      $.press 'e'
      @delay 100, next
    map['e~'] = => @useE true, next

    map.j = => @jump next
    map.s = => @sprint next

    map.t = =>
      $.press 'r'
      @delay 100, next
    map.tt = =>
      $.press 'r'
      $.setTimeout =>
        $.press 'r'
        @delay 50, next
      , 50

    # console.log "Tactic: #{item}"
    callback = map[item]
    if !callback and ($.type item) == 'number'
      callback = => @delay item, next

    if callback then callback()

  get: (list, g = 0, i = 0) ->
    if g >= $.length list then return false
    group = list[g]
    if i >= $.length group then return false
    return group[i]

  jump: (callback) ->
    movement.jump()
    unless movement.isMoving
      @delay 450, callback
    else @delay 550, callback

  ongoing: (cbA, cbB, isNot = false) ->

    unless isNot
      if skillTimer.listDuration[party.current]
        @delay 50, cbA
      else @delay 50, cbB
    else
      if skillTimer.listDuration[party.current]
        @delay 50, cbB
      else @delay 50, cbA

  onMoving: (cbA, cbB, isNot = false) ->

    unless isNot
      if movement.isMoving
        @delay 50, cbA
      else @delay 50, cbB
    else
      if movement.isMoving
        @delay 50, cbB
      else @delay 50, cbA

  reset: ->

    $.clearTimeout timer.tacticDelay

    if @isPressed['l-button']
      $.click 'left:up'

    @isActive = false

  sprint: (callback) ->
    movement.sprint()
    @delay 100, callback

  start: ->

    if @isActive then return

    listTactic = @validate()
    unless listTactic
      $.click 'left:down'
      return

    @isActive = true

    wait = 1e3 - ($.now() - party.tsSwitch)
    if wait < 200
      wait = 200

    @execute listTactic, 0, 0

  stop: ->

    if @isActive
      @reset()
      return

    $.click 'left:up'

  switchTo: (n, callback) ->

    unless @isActive
      return

    $.press n
    party.switchTo n
    @delay 200, callback

  useE: (isHolding, callback) ->

    unless skillTimer.listCountDown[party.current]
      player.useE isHolding
      @delay 100, callback
      return

    @delay 50, callback

  validate: ->

    unless Scene.name == 'normal' then return false

    {name} = party
    unless name then return false

    listTactic = Character.data[name].onLongPress
    unless listTactic then return false

    return listTactic

# execute
tactic = new TacticX()