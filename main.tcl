#!/usr/bin/wish

proc title {game category} {
	ttk::label .title -style Title.TLabel -text "$game\n$category"
	pack .title -fill x
}

proc timer {} {
	set ::timerEpoch 0
	set ::timerTime 0
	set ::timerLabel "XX:XX.XX"
	trace add variable ::timerEpoch write updateTimer
	trace add variable ::timerTime write updateTimer

	ttk::label .timer -style Timer.TLabel -textvariable ::timerLabel
	pack .timer -fill x
}
proc updateTimer {args} {
	set time [expr $::timerTime - $::timerEpoch]
	set ::timerLabel [formatDuration $time]
}
proc formatDuration {micros} {
	set hrs    [expr $micros / $::HOUR]
	set micros [expr $micros % $::HOUR]
	set mins   [expr $micros / $::MINUTE]
	set micros [expr $micros % $::MINUTE]
	set secs   [expr $micros / $::SECOND]
	set micros [expr $micros % $::SECOND]
	set centis [expr $micros / $::CENTI]

	if {$hrs > 0} {
		set hrs "$hrs:"
	} else {
		set hrs {}
	}
	format "%s%.2d:%.2d.%.2d" $hrs $mins $secs $centis
}
set CENTI 10000
set SECOND [expr $CENTI* 100]
set MINUTE [expr $SECOND * 60]
set HOUR [expr $MINUTE * 60]

proc splits {config} {
	ttk::treeview .splits -style Splits.Treeview -columns {delta time} -selectmode none -show tree
	.splits column delta -width 50 -stretch false
	.splits column time -width 85 -stretch false
	bind .splits <<TreeviewSelect>> updateSplit	
	pack .splits -fill both -expand true

	parseSplits {} $config
}
proc parseSplits {parent config} {
	foreach {name body} $config {
		set id [.splits insert $parent end -text $name]
		if {$body ne "."} {
			parseSplits $id $body
		}
	}
}
proc updateSplit {} {
	# Close everything
	set id [.splits selection]
	while {$id ne ""} {
		set id [.splits parent $id]
		foreach child [.splits children $id] {
			.splits item $child -open false
		}
	}

	# Open just enough to see the new active split
	.splits see [.splits selection]
}
proc timerStarted {} {
	return [llength [.splits selection]]
}

proc pipe {path} {
	set f [open $path {RDONLY NONBLOCK}]
	chan configure $f -blocking false
	chan event $f readable "readEvent $f"
}
proc readEvent {f} {
	if {[chan gets $f ev] < 0} {
		chan event $f readable
		error "Splitter disconnected"
		exit 1
	}
	set time [lindex $ev 0]
	set type [lindex $ev 1]

	switch -nocase -- $type {
		BEGIN {
			set ::timerEpoch $time
			.splits selection set [firstLeaf .splits {}]
		}

		END {
			.splits selection set {}
		}

		SPLIT {
			set id [.splits selection]
			.splits selection set [nextLeaf .splits $id]
		}

		TIME {}
	}

	if {[timerStarted] && $time > $::timerTime} {
		set ::timerTime $time
	}
}

proc firstLeaf {pathname item} {
	set children [$pathname children $item]
	while {[llength $children]} {
		set item [lindex $children 0]
		set children [$pathname children $item]
	}
	return $item
}
proc nextLeaf {pathname item} {
	while {[$pathname next $item] eq {}} {
		set item [$pathname parent $item]
		if {$item eq {}} {
			return
		}
	}
	set item [$pathname next $item]
	return [firstLeaf $pathname $item]
}

title "Portal 2" "Single Player (Quicksaves)"
timer
splits {
	"Chapter 1" {
		"Chamber 1" .
		"Chamber 2" .
		"Chamber 3" .
	}
	"Chapter 2" {
		"Chamber 4" .
		"Chamber 5" .
		"Chamber 6" {
			"Part 1" .
			"Part 2" .
		}
	}
	"Chapter 3" .
	"Chapter 4" {
		"Part 1" .
		"Part 2" .
	}
}

ttk::style configure Title.TLabel -font "Helvetica 14"

ttk::style configure Timer.TLabel -font "Helvetica 24 bold"
ttk::style configure Ahead.Timer.TLabel -foreground #64ff64
ttk::style configure Behind.Timer.TLabel -foreground #ff3232

ttk::style configure Splits.Treeview -font "Helvetica 12"
.splits tag configure best -foreground #ffdc00
.splits tag configure aheadGain -foreground #50d200
.splits tag configure aheadLose -foreground #b4ff78
.splits tag configure behindGain -foreground #c80000
.splits tag configure behindLose -foreground #ffdc00

pipe /tmp/riftev
