# Debug test script. It evaluates arbitrary Tcl scripts on the global level and returns the result.
# Send scripts in the format: { ... script ... }. So, surrounded by braces. You can have newlines between braces. Or separate statements with ; as usual.
# The only syntax requirement is that braces within {} are matched, but that's a Tcl script requirement anyway.
# The results is in the form: <result code> {<result string>}
# Result codes: 0 = OK, 1 = ERROR, (2 = RETURN, 3 = BREAK, 4 = CONTINUE. 2-4 should never happen.)

# Open test socket and wait for scripts to execute.
if {![info exists ::testsock]} {
	set ::testsock [socket -server testaccept -myaddr 0.0.0.0 45678]
}

proc testaccept {s addr port} {
	global testbuf
	#  putlog "Incoming test connection from $addr:$port ($s)"
	fconfigure $s -buffering line -blocking 0
	fileevent $s readable [list checkscript $s]
	dict set testbuf $s ""
}

proc checkscript {s} {
	global testbuf
	#  putlog "ping $s"
	if {[gets $s line] < 0} {
		if {![fblocked $s]} {
			putlog "EOF from $s"
			close $s
		}
		return
	}
	#  putlog "Got line: $line"
	if {[dict get $testbuf $s] eq "" && [string index $line 0] ne "\x7b"} {
		putlog "ERROR on testsocket $s! Send scripts surrounded by {} only!"
		close $s
		return
	}
	dict append testbuf $s "$line\n"
	if {[info complete [dict get $testbuf $s]]} {
		#     putlog "Evaluating script on $s: '[dict get $testbuf $s]'"
		set code [catch [list uplevel [lindex [dict get $testbuf $s] 0]] str]
		puts $s "$code {$str}"
		close $s
		dict set testbuf $s ""
	}
}
