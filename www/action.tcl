# /packages/soap-gateway/www/action.tcl

# page contract not included due to cost of parsing payload - (not necessary)

# generate temp file name
set tmp [ns_tmpnam]

# open it
set f [open $tmp w+]

# perform file ops in safe block to ensure tmp file unlink
# (yes, this is a back asswards approach)
set err [catch {
	
	# dump payload to file - there's gotta be a better way to get the content
	ns_conncptofp $f
	
	# get file size
	set size [tell $f]
	
	# limit incoming envelope size to 1/4 meg
	if { $size > 262144 || $size < 0 } {
			
		# throw it
		error "payload too large"			
	
	}
	
	# seek to beginning
	seek $f 0
	
	# read file contents into SOAP envelope var
	set env [read $f $size]
	
} msg] 

# test for error
if { $err != 0 } {

	# make em' wait
	ns_sleep 5

	# prep
	set savedInfo {}
	
	# advise
	global errorInfo
	
	# test
	if { [info exists errorInfo] != 0 } {
	
		# preserve error info
		set savedInfo $errorInfo
		
	} 

	# release file
	catch { close $f }
	
	# unlink file
	ns_unlink $tmp

	# throw
	error "$msg\nfile: $tmp" $savedInfo

} else {
	
	# release file
	catch { close $f }

	# unlink file
	ns_unlink $tmp


}

# invoke envelope using lib functions and return
ns_return 200 text/xml [soap::server::invoke $env]
