set ::gravX 0
set ::gravY 1

set ::velX 1
set ::velY 1

set ::taxiID 0

proc eventLoop {} {
  if {$::taxiID == 0} { return }

  incr ::velX $::gravX
  incr ::velY $::gravY

  set coord [.c coords 1]
  if {$::velY < 0 || [lindex $coord 3] < [.c cget -height]} {
     .c move $::taxiID $::velX $::velY
  }
  after 1000 eventLoop
}

proc thrustUp {} {
  incr ::velY -10
}

proc thrustLt {} {
  incr ::velX -5
}

proc thrustRt {} {
  incr ::velX 5
}

pack [frame .fVel] -side top
pack [label .fVel.lLX -text "X Velocity:"] -side left
pack [label .fVel.lVX -textvariable velX] -side left
pack [label .fVel.lVY -textvariable velY] -side right
pack [label .fVel.lLY -text "Y Velocity:"] -side right

pack [canvas .c] -side top

set ::taxiID [.c create rectangle 10 10 20 20 -fill yellow]

bind . <Up>    thrustUp
bind . <Left>  thrustLt
bind . <Right> thrustRt

after 1 eventLoop

