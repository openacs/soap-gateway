# Expects "title" and "header" and "context_bar"

if { ![info exists context_bar] } {
    set context_bar {}
}

if ![info exists header_stuff] {
	set header_stuff {}
}

if ![info exists title] {
	
	# clear
	set title {}
	
}

ad_return_template
