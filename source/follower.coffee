# function

class FollowerX

  intervalCheck: 1e3
  isMoving: false
  tsCheck: 0

  constructor: ->
    client.on 'tick', @check

  check: ->

    unless Scene.name == 'normal' then return

    now = $.now()
    unless now - @tsCheck >= @intervalCheck then return
    @tsCheck = now

    unless @detect()
      @rotate()
      return

    @move()

  detect: ->

    start = client.point [3, 2]
    end = client.point [14, 21]

    [x, y] = $.findColor 0x408000, start, end
    unless x * y > 0 then return false

    [x0, y0] = client.point [8.5, 11.5]

    diff = y - y0
    unless diff > 0 then return false

    return ($.abs x - x0) < diff

  move: ->
    $.press 's:down'
    $.setTimeout ->
      $.press 'space'
      $.setTimeout ->
        $.press 'space'
        $.setTimeout ->
          $.press 's:up'
        , 400
      , 200
    , 200

  rotate: ->
    $.press 'x'
    $.press 'd'
    $.press 'm-button'

# execute

follower = new FollowerX()