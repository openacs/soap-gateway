# /packages/soap-gateway/www/toolbar.tcl

# layout inspired by bug-tracker

# safety
if ![info exists caption] {

    # clear
    set caption {}
}

# clear for tools
set tools []

# add standard tools
set defaults [list help services tests]

# package id
set pid [soap::package_id -throw f]

# verify
if { $pid == 0 } {
	
    # must be just starting out - clear everything
    set defaults [list]
	
# test for admin user
} elseif { [soap::server::has_permission $pid admin] != 0 } { 

    # add em'
    lappend defaults admin permissions
    
}

# update tools list
foreach default $defaults {

    # test current list and skip if caption
    # ??? if $default equal to caption, then assume $default tool page is current
    if { [lsearch $tools $default] < 0 && ![string equal -nocase $default $caption] } {
	
	# add
	lappend tools $default
    }
}

# get href base
set base [soap::get_base_url]

# create multirow
multirow create toolbar symbol url

# loop through list
foreach tool $tools {

    # switch
    case $tool {
	help {
	    # add
	    multirow append toolbar help [file join $base doc]
	}
	services {
	    # add
	    multirow append toolbar services [file join $base ]
	}
	admin {
	    # add
	    multirow append toolbar admin [file join $base admin ]
	}
	tests {
	    # add
	    multirow append toolbar tests [file join $base tests ]
	}
	permissions {
	    # set href
	    set url "/permissions/one?object_id=$pid"

	    # add
	    multirow append toolbar permissions $url

	}
    }
}

ad_template_return