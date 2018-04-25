ad_library {

    SOAP API for registering and handling TCL services located in the
    library directory.
    
    @author William Byrne (WilliamB@ByrneLitho.com)
    @author Nick Carroll (ncarroll@ee.usyd.edu.au)
}


namespace eval soap::server::lib {}


ad_proc -public soap::server::lib::library_new {
    path
} {
    @param path
} {
    db_exec_plsql library_new {}
}


ad_proc -public soap::server::lib::library_update {
    library_id 
    path 
} {
    @param library_id
    @param path
} {
    db_exec_plsql update_library {}
}

ad_proc -public soap::server::lib::library_delete {
    library_id 
} {
    @param library_id
} {
    db_exec_plsql delete_library {}		
}


ad_proc -public soap::server::lib::library_get_path {
    library_id 
} {
    @param library_id
} {
    set path [db_string select_path {} -default {} ]	
    
    # return
    return $path
}


ad_proc -private soap::server::lib::is_library_valid {
    library
} {
    @param library
} {

    # get root without tail /
    set root [file join [acs_root_dir]]

    # test for directory
    if [file isdirectory [file join $root $library]] {
	# append wildcard
	set library [file join $library *.tcl]
    }

    # scan  glob list
    foreach f [glob -nocomplain -directory $root $library] {
	# verify extension
	if ![string equal -nocase [file extension $f] {.tcl}] {
	    # skip it
	    continue
	}
	# yup
	return 1	
    }
    # clean
    return 0
}

ad_proc -private soap::server::lib::is_library_dirty {
    library
} {
    @author William Byrne
} {
    # get root without trailing /
    set root [file join [acs_root_dir]]

    # get len + 1 for eventual /
    set len [expr [string length $root] + 1]

    # test for directory
    if [file isdirectory [file join $root $library]] {
	# append wildcard
	set library [file join $library *.tcl]
    }

    # scan  glob list
    foreach f [glob -nocomplain -directory $root $library] {
	# verify extension
	if ![string equal -nocase [file extension $f] {.tcl}] {
	    # skip it
	    continue
	}

	# get mtime
	set mtime [file mtime $f]

	# get short
	set short [string range $f $len end]

	# check to see if registered in loader
	if ![nsv_exists apm_reload_watch $short] {
	    # remove from mtime
	    catch { nsv_unset apm_library_mtime $short }
	}

	# get property without root
	set cached [soap::get -set apm_library_mtime $short]

	# test
	if { $cached == {} || $mtime != $cached } {
	    # dirty
	    return 1
	}
    }
    # clean
    return 0
}


ad_proc -private soap::server::lib::library_get_paths {
} {
    @author William Byrne
} {
    # init
    set paths {}

    # loop through libraries
    db_foreach select_lib_paths {} { 
	# append name
	lappend paths $path
    }
    
    # return names
    return $paths
}


ad_proc -public soap::server::lib::update_libraries {
    {-stop 0}
    {libraries [list]}
} {
    @author William Byrne
} {
    # get root without trailing /
    set root [file join [acs_root_dir]]

    # get len + 1 for eventual /
    set len [expr [string length $root] + 1]
    
    # loop through libraries
    foreach lib $libraries {

	# test for directory
	if [file isdirectory [file join $root $lib]] {
	    # append wildcard
	    set lib [file join $lib *.tcl]
	} elseif ![string equal -nocase [file extension $lib] {.tcl}] {
	    # skip it
	    continue
	}

	# scan  glob list
	foreach f [glob -nocomplain -directory $root $lib] {
	    # add to watch without root
	    soap::server::lib::watch -stop $stop [string range $f $len end]
	}
    }
    # return something
    return 1
}


ad_proc -private soap::server::lib::true {
    value
} {
    @author William Byrne
} {
    # handle ints > 1 || < 0
    if [string is integer $value] {
	# eval
	return [expr $value != 0 ? 1 : 0]
    }

    # empty value is false
    return [expr [string length $value] > 0 && [string is true $value] ? 1 : 0]
}


ad_proc -public soap::server::lib::watch {
    {-stop 0}
    file
} {
    @author William Byrne
} {
    # setup result
    set result 1

    # test for stop
    if [soap::server::lib::true $stop] {
	# safe
	if [catch {
	    # stop watch
	    nsv_unset apm_reload_watch $file
	}] {
	    # egats
	    set result 0
	}
	# safe
	catch {
	    # remove cache
	    nsv_unset apm_library_mtime $file
	}

    } else {
	# add
	apm_file_watch $file	
    }

    # return status
    return $result
}


ad_proc -public soap::server::lib::boot_libraries {
} {
    @author William Byrne
} {
    # get paths
    set paths [soap::server::lib::library_get_paths]

    # send to update
    foreach lib $paths {
        soap::server::lib::update_libraries $lib
    }

    # return something
    return 1
}


ad_proc -private soap::server::lib::get_library_doc {
    service
} {
    @param service
} {
    # get a command from namespace
    set procs [info commands [format "::sg::%s" $service]]
    
    # decl source path
    set path {}
    
    # any ?
    if [llength $procs] {
	# get first one
	set proc [lindex $procs 0]

	# safe 
	catch {
	    # get the documentenation array	for the method
	    array set doc_elements [nsv_get api_proc_doc \
                [format "::sg::%s::%s" $service $proc]]
	    
	    # get script path
	    set path $doc_elements(script)
	}
    }
    
    # check path
    if { $path == {} } {
	
	# try lib directory
	set path "packages/soap-gateway/lib/[string tolower $service]-procs.tcl"	
    }

    # decl result
    set result {}
    
    # try to get doc info from file
    catch {
	# get source file docs - force lower case convention
	array set doc_elements [nsv_get api_library_doc $path]
	
	# update and remove curlies
	set result [join $doc_elements(main)]
    }			

    # return whatever we got
    return $result
}


ad_proc -public soap::server::lib::method_new {
    namespace_id 
    method 
    idl 
    idl_style 
    proc
    notes 
    user_id 
    peeraddr 
    package_id
} {
    @param namespace_id 
    @param method 
    @param idl 
    @param idl_style 
    @param proc
    @param notes 
    @param user_id 
    @param peeraddr 
    @param package_id
} {
    # create new  - 
    db_exec_plsql method_new {}
}


ad_proc -public soap::server::lib::namespace_new {
	service 
	uri 
	notes 
	user_id 
	peeraddr 
	package_id
} {
    @param service
    @param uri
    @param notes
    @param user_id
    @param peeraddr
    @param package_id
} {
    # db new 
    db_exec_plsql namespace_new {}
}


ad_proc -public soap::server::lib::namespace_update {
    namespace_id 
    service 
    uri 
    notes
} {
    @param namespace_id 
    @param service 
    @param uri 
    @param notes
} {
    db_exec_plsql namespace_update {}
}


ad_proc -private soap::server::lib::get_proc_doc {
    proc
} {
    @param proc
} {
    # decl result
    set result {}
    
    # safe
    catch {
	
	# remove sg namespace
	if { [string equal -length 6 ::sg:: $proc] } {
	    # trim ::
	    set proc [string range $proc 2 end]
	}
	
	# get doc set for procedure
	array set doc_elements [nsv_get api_proc_doc $proc]
	
	# get main documentation and remove curlies
	set result [join $doc_elements(main)]
    }
    
    # return procedure doc
    return $result
}


ad_proc -private soap::server::lib::idl_to_xsd { 
    style
    idl
} {
    @param style
    @param idl
} {
    # verify style
    if { [string compare -nocase $style "C"] != 0 } {

	# not yet supported
	soap::fault::unsupported "Unsupported IDL style: $style\n Use 'C'"
	
    }

    # set up regexp expression for "C" style function 
    set expr [soap::wsdl::get_style_parser_expr C]
	
    # invoke regexp
    regexp $expr $idl {} type method argz

    # map type
    set xtype [soap::wsdl::map_ctype_to_xtype $type]

    # verify
    if { [llength $xtype] > 1 } {

	# not yet supported
	soap::fault::unsupported "cannot spec non simple types: $type"
	
    }

    # setup arg list
    set xargs {}

    # get arg parser expr
    set expr [soap::wsdl::get_style_parser_expr -argpart 1 C]
	
    # loop through args
    foreach a [split $argz ,] {
		
	# split arg type from its name
	if ![regexp $expr $a {} typ nam] {
	    
	    # format problem
	    error "unexpected argument format: $a"
	    
	}
		
	# add arg to param order var
	lappend order $nam
		
	# map type
	set xtype2 [soap::wsdl::map_ctype_to_xtype $typ]
	
	# get component count
	set cnt [llength $xtype2]
	
	# test for simple
	if { $cnt == 1 } {
	    
	    # append to arg list
	    lappend xargs [list [lindex $xtype2 0] $nam]
	    
	} else {
	    
	    # not yet supported
	    soap::fault::unsupported "cannot spec non simple types: $a, $xtype2"
	}
    }

    # build return
    return [list $xtype $method $xargs]
}


ad_proc -public soap::server::lib::method_update {
    method_id 
    method 
    idl 
    idl_style 
    proc
    notes
} {
    @param method_id 
    @param method 
    @param idl 
    @param idl_style 
    @param proc
    @param notes
} {
    # update existing
    db_exec_plsql method_update {}
}


ad_proc -private soap::server::lib::import_service {
    {-force 0}
    {-proc {}}
    service
} {
    @param service
} {
    # set connection vars
    set user_id [ad_conn user_id]
    set peeraddr {}
    set package_id [ad_conn package_id]
    
    # verify workspace namespace
    set nid [soap::server::namespace_get_id $service]
    
    # test
    if { $nid == -1 } {
	
	# get doc
	set notes [soap::server::lib::get_library_doc $service]
	
	# create
	soap::server::lib::namespace_new \
            $service "http://$service.openacs.org/methods" \
            $notes $user_id $peeraddr $package_id
	
	# clear
	unset notes
	
	# get id
	set nid [soap::server::namespace_get_id $service]
	
    } elseif { $force } {
	
	# query for namespace attributes
	db_1row namespace_select {}
	
	# get doc
	set notes [soap::server::lib::get_library_doc $service]
	
	# update with new notes
	soap::server::lib::namespace_update $nid $service $uri $notes	
    }
    
    # get public procs for namespace
    
    # set method parameters - idl style
    set idl_style {C}
    
    # build procs list
    set procs [soap::get_source_procs $service]
    
    # test for optional proc arg
    if { $proc != {} } {
	
	# test for ns qualifier ??? (weak)
	if ![string equal -length 6 $proc {::sg::}] {
	    # fix up
	    set proc [format "::sg::%s::%s" $service $proc]
	}
	
	# contained in list
	if { [lsearch -exact $procs $proc] >= 0 } {
	    # use
	    set procs [list $proc]
	} else {
	    # clear, not found
	    set procs {}
	}
    }

    # loop
    foreach proc $procs {
        # get idl
	set idl [soap::get_source_idl $proc]

	# get notes
	set note [soap::server::lib::get_proc_doc $proc]
	
	# try
	if [catch {
	    # decompose IDL
	    set xsd [soap::server::lib::idl_to_xsd $idl_style $idl]
	} msg] {
	    # report
	    soap::fault::raise "Error importing: $proc, idl: $idl\n$msg"
	}
	
	# get method name from idl
	set method [lindex $xsd 1]
	
	# remove namespace
	set proc [namespace tail $proc]
	
	# verify workspace method
	set mid [soap::wsdl::method_get_id $nid $method]
	
	# test
	if { $mid == -1 } {
	    # create
	    soap::server::lib::method_new $nid $method $idl $idl_style \
                          $proc $note $user_id $peeraddr $nid
	    
	    # test for 'login'
	    if [string equal -nocase $method "LOGIN"] {
		# get method id		
		set mid [soap::wsdl::method_get_id $nid $method]
		
		# verify
		soap::fault::assert {$mid != -1} "Error retrieving 'login' method id: $method => $mid"
		
		# get public
		set public_id [acs_magic_object the_public]
		
		# get invoke symbol
		set invoke [soap::server::get_invoke_permission_moniker]
		
		# grant invoke permission to public
		permission::grant -party_id $public_id -object_id $mid -privilege $invoke

		# verify
		set ok [permission::permission_p -party_id $public_id -object_id $mid -privilege $invoke]
		soap::fault::assert $ok "Error granting '$invoke' permission to public"
	    }
	} elseif { $force } {
	    # update
	    error "soap::server::lib::method_update $mid $method $idl $idl_style $proc $note"
	}
    }

    # return namespace id
    return $nid   
}