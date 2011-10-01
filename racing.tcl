load ./sdlmix.dll

set ::music 0

proc toggleMusic {} {
	if {$::music} {
		sdl::mix::music ""
		set ::music 0
	} else {
		sdl::mix::music [lindex [glob *.mod] 0]
		set ::music 1
	}
}
toggleMusic

set ::pi       [expr 4 * atan(1)]
set ::carAng   [expr 5 * $pi / 8]
set ::deg      [expr $pi / 180]

proc reset {} {
	set ::carSpeed  0
	set ::carX     15
	set ::carY     10
}
reset

# construct a triplet of coords
proc makeCar {r t offX offY} {
	set ret ""

	# point 1, right side
	lappend ret [expr $r * cos($t+90) + $offX]
	lappend ret [expr $r * sin($t+90) + $offY]

	# point 2, left side
	lappend ret [expr $r * cos($t-90) + $offX]
	lappend ret [expr $r * sin($t-90) + $offY]

	# point 3, front
	lappend ret [expr 2*$r * cos($t) + $offX]
	lappend ret [expr 2*$r * sin($t) + $offY]

	set minX [expr min([lindex $ret 0],[lindex $ret 2],[lindex $ret 4])]
	set minY [expr min([lindex $ret 1],[lindex $ret 3],[lindex $ret 5])]

	set maxX [expr max([lindex $ret 0],[lindex $ret 2],[lindex $ret 4])]
	set maxY [expr max([lindex $ret 1],[lindex $ret 3],[lindex $ret 5])]

	set cwidth  [.c cget -width]
	set cheight [.c cget -height]

	if {$minX < 0} {
		set ::carX [expr $::carX - $minX]
		set ::carSpeed 0
	} elseif {$maxX > $cwidth} {
		set ::carX [expr $::carX - $maxX + $cwidth]
		set ::carSpeed 0
	}

	if {$minY < 0} {
		set ::carY [expr $::carY - $minY]
		set ::carSpeed 0
	} elseif {$maxY > $cheight} {
		set ::carY [expr $::carY - $maxY + $cheight]
		set ::carSpeed 0
	}

	return $ret
}

proc incrAng {} {
	set amt [expr (abs($::carSpeed)+3) / 4.0 * $::deg]
	set ::carAng [expr $::carAng + $amt]
	if {$::carAng > 2 * $::pi} {
		set ::carAng 0
	}
}

proc decrAng {} {
	set amt [expr (abs($::carSpeed)+3) / 4.0 * $::deg]
	set ::carAng [expr $::carAng - $amt]
	if {$::carAng < 0} {
		set ::carAng [expr 2 * $::pi]
	}
}

proc eventLoop {} {
	# adjust position for speed
	set ::carX [expr $::carX + $::carSpeed/4.0 * cos($::carAng)]
	set ::carY [expr $::carY + $::carSpeed/4.0 * sin($::carAng)]

	# redraw car
	.c coords $::carId [makeCar 10 $::carAng $::carX $::carY]

	after 30 eventLoop
}

pack [canvas .c] -side top -expand 1 -fill both

set ::carId [.c create poly 10 0 20 10 0 20 -fill blue -tags car]

bind .c <Left>  {decrAng}
bind .c <Right> {incrAng}
bind .c <Up>    {incr ::carSpeed}
bind .c <Down>  {incr ::carSpeed -1}
bind .c <Enter> {focus %W}

bind .c <m> {toggleMusic}

bind .c <Configure> {
	%W configure -width  [winfo width  .c]
	%W configure -height [winfo height .c]
}

eventLoop

