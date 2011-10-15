#### setup
package require XOTcl
namespace import xotcl::*

load ./sdlmix.dll

#### globals
set ::pi  [expr 4 * atan(1)]
set ::deg [expr $pi / 180]

#### Car class
Class create ^Car

^Car instproc init {} {
	my instvar carAng carSpeed carX carY

	set carAng   [expr 5 * $::pi / 8]
	set carSpeed  0
	set carX     15
	set carY     10
}

# construct a triplet of coords
^Car instproc makeCar {} {
	my instvar carAng carSpeed carX carY

	set r 10 ;# car "radius" (size)
	set t $carAng
	set offX $carX
	set offY $carY

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
		set carX [expr $carX - $minX]
		set carSpeed 0
	} elseif {$maxX > $cwidth} {
		set carX [expr $carX - $maxX + $cwidth]
		set carSpeed 0
	}

	if {$minY < 0} {
		set carY [expr $carY - $minY]
		set carSpeed 0
	} elseif {$maxY > $cheight} {
		set carY [expr $carY - $maxY + $cheight]
		set carSpeed 0
	}

	return $ret
}

^Car instproc move {} {
	my instvar carX carY carSpeed carAng

	# adjust position for speed
	set carX [expr $carX + $carSpeed/4.0 * cos($carAng)]
	set carY [expr $carY + $carSpeed/4.0 * sin($carAng)]
}

^Car instproc accel {{amt 1}} {
	my instvar carSpeed
	incr carSpeed $amt
}

^Car instproc incrAng {} {
	my instvar carAng carSpeed

	set amt [expr (abs($carSpeed)+3) / 4.0 * $::deg]
	set carAng [expr $carAng + $amt]
	if {$carAng > 2 * $::pi} {
		set carAng 0
	}
}

^Car instproc decrAng {} {
	my instvar carAng carSpeed

	set amt [expr (abs($carSpeed)+3) / 4.0 * $::deg]
	set carAng [expr $carAng - $amt]
	if {$carAng < 0} {
		set carAng [expr 2 * $::pi]
	}
}

#### cars
^Car create p1car ;# player 1 car

#### music
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

proc eventLoop {} {
	p1car move

	# redraw car
	.c coords $::carId [p1car makeCar]

	after 30 eventLoop
}

pack [canvas .c] -side top -expand 1 -fill both

set ::carId [.c create poly 10 0 20 10 0 20 -fill blue -tags car]

bind .c <Left>  {p1car decrAng}
bind .c <Right> {p1car incrAng}
bind .c <Up>    {p1car accel}
bind .c <Down>  {p1car accel -1}
bind .c <Enter> {focus %W}

bind .c <m> {toggleMusic}

bind .c <Configure> {
	%W configure -width  [winfo width  .c]
	%W configure -height [winfo height .c]
}

eventLoop

