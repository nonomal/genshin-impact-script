# @ts-check

aboutCaps = ->
  Client.on 'activate', -> Native 'SetCapsLockState, Off'
  $.on 'CapsLock', -> $.beep()

aboutClient = ->
  report = ->
    {x, y, width, height} = Window2.bounds
    $.forEach [
      "#client/bounds: #{x}, #{y}, #{width}, #{height}"
      "#client/is-fullscreen: #{Window2.isFullScreen}"
    ], (msg) -> console.log msg

  Window2.focus()

  Timer.add 200, ->
    Client.emit 'enter'
    report()

aboutDebug = ->
  unless Config.get 'misc/use-debug-mode' then return
  $.on 'alt + f9', ColorManager.pick

aboutSkillTimer = ->

  unless Config.get 'skill-timer/enable' then return

  # auto scan

  token = 'change.auto-scan'

  autoScan = ->
    unless Scene.is 'free', 'single' then return
    Scene.off token
    Party.scan()

  addListener = ->
    Scene.off token
    Scene.on token, autoScan

  Scene.on 'change', ->
    unless Scene.is 'party' then return
    addListener()

  addListener()
  Scene.emit token

  # clear party

  Scene.on 'change', ->
    unless Party.size then return
    unless Scene.is 'normal' then return
    if Scene.is 'single' then return
    $.trigger 'alt + f12'

boot = (callback) ->

  list = [
    # ---start---
    Client
    ColorManager
    Config
    console
    Dictionary
    Fishing
    Hud
    Indicator
    Picker
    Recorder
    Replayer
    Scene
    Skill
    Sound
    Status2
    Tactic
    Window2
    Buff
    Camera
    Character
    Gdip
    Jumper
    Menu2
    Movement
    Party
    Party2
    Alice
    Controller
    # ---end---
  ]

  for m in list
    unless $.isFunction m.init
      $.setTimeout ->
        boot callback
      , 100
      return

  $.forEach list, (m) -> m.init()
  callback()
  return

# boot
boot ->
  aboutCaps()
  aboutClient()
  aboutSkillTimer()
  aboutDebug()

# exit
OnExit ->
  Sound.unmute()
  Window2.window.setPriority 'normal'