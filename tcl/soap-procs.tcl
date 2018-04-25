ad_library {
    SOAP utils API.

    Based on William Byrne's soap-gateway implementation.

    @author William Byrne (WilliamB@ByrneLitho.com)
    @author Nick Carroll (ncarroll@ee.usyd.edu.au)
    @creation-date 2004-09-24
    @cvs-id $Id$
}


namespace eval soap {}

# Libraries in the lib directory must run in the sg namespace.
namespace eval sg {}


ad_proc -public soap::check_str_len {
    string
    length
    {warning {string is too long}}
} {
    Verifies the string does not exceed length
    
    @param string
    @param length
    @param warning
} {
    if { [string length $string] > $length } {
	# throw
	soap::fault::raise $warning
    }   
}


# create login wrapper for sg services
ad_proc -public soap::login {
    user
    password
} {
    @param user
    @param password
} {
    # normalize id
    set email [string tolower $user]
    
    # search for
    set result [db_0or1row user_login_user_id_from_email {
	select user_id, member_state, email_verified_p
	from cc_users
	where email = :email}]
    
    # good house keeping		
    db_release_unused_handles
        
    # verify
    if { $result == 0 } {
	# rejected	
	soap::fault::unauthorized "Access Denied\n$email not registered"
    }
    
    # again
    if { $member_state != "approved" || $email_verified_p == "f" } {
	# rejected	
	soap::fault::unauthorized "Access Denied\nMember: $member_state\ne-mail: $email_verified_p"
    }
    
    # and again
    if { ![ad_check_password $user_id $password] } {
	# rejected	
	soap::fault::unauthorized "Access Denied\nInvalid user or password"
    }
    
    # is this necessary ???
    ad_user_logout
    
    # log user
    ad_user_login -forever=1 $user_id
    
    # return 0
    return 0	
}


# create logout wrapper for sg services
ad_proc -public soap::logout {
} {
    @author William Byrne
} {
    # clear cookies
    ad_user_logout
}


ad_proc -private soap::method_check {
    method_id
} {
    @param method_id
} {
    # exec db
    set exists [db_string method_exists {} -default 0]
    
    # test result
    if { $exists == 0 || [string is integer $exists] != 1 } {
	# failed, throw
	soap::fault::raise "invalid method id: $namespace_id"
    }
    # valid
}


ad_proc -public soap::namespace_delete {
    namespace_id 
} {
    @param namespace_id
} {
    db_exec_plsql namespace_delete {}		
}


ad_proc -public soap::method_delete {
    method_id 
} {
    @param method_id
} {
    # db update
    db_exec_plsql delete_method {}		
}


ad_proc -public soap::package_id {
    {-throw 1}
} {
    @author William Byrne
} {
    # try and get id
    set pid [apm_package_id_from_key soap-gateway]

    # test 
    if { $pid != 0 } {
	# done
	return $pid
    }

    # memoize got fed bad stuff - clear it
    util_memoize_flush_regexp "apm_package_id_from_key_mem soap-gateway"

    # try again
    set pid [apm_package_id_from_key soap-gateway]

    # test
    if { $pid != 0 } {
	# done
	return $pid
    }

    # crap - get connection
    set pid [ad_conn package_id]

    # verify
    if [string equal [apm_package_key_from_id $pid] soap-gateway] {
	#done
	return $pid
    }	

    # how 'bout the db
    set pid [db_string select_pid {} -default 0]

    # test
    if { $pid != 0 } {
	# done
	return $pid
    }

    # throw
    if [soap::server::lib::true $throw] {
	soap::fault::raise "Cannot get package id for soap-gateway"	
    }

    # return error
    return 0
}


ad_proc -private soap::get {
    {-set sg_properties}
    property
} {
    @param property
} {
    # check set
    if ![nsv_exists $set $property] {
	# return empty
	return {}
    }
    
    # get em
    return [nsv_get $set $property]
}


ad_proc -private soap::namespace_get_names {
} {
    @author William Byrne
} {
    # init
    set names {}

    # loop through namespaces
    db_foreach select_services {} { 
	# append name
	lappend names $service
    }

    # return names
    return $names
}


ad_proc -private soap::query_services {
    {-unpublished 0}
    {-published 1}
    
} {
    @author William Byrne
} {
    
    # get active services
    set services [soap::namespace_get_names]
    
    # test for request
    if $unpublished {
	# decl unpublished list
	set unpub [list]
	
	# create lower case services
	set lowercase_services [string tolower $services]
	
	# get all namespaces under ::sg
	foreach service [namespace children ::sg] {
	    # get child portion of namespace only - skip 
	    # '::sg::' portion of string
	    set child [namespace tail $service]
	    
	    # search for existing
	    if { [lsearch $lowercase_services [string tolower $child]] < 0 } {
		# add to unpublished list
		lappend unpub $child
	    }
	}
	
	# want all
	if $published {
	    # add to services
	    return [concat $services $unpub]
	} else {
	    # return list
	    return $unpub
	}
    }
    
    # return services list
    return $services
}


ad_proc -private soap::get_idl_help  {
} {
    @author William Byrne
} {

    # return simple instructions
    set help {
	<p style="margin-top:4px">
	Use "C" style function syntax. Data type map:
	<table width="100%">
	<tr style="line-height:90%"><td><u><b>Data Type</b></u></td><td><u><b>XML Schema</b></u></td></tr>
	<tr style="line-height:90%"><td>char, char[], string</td><td>xsd:string</td></tr>
	<tr style="line-height:90%"><td>int, long</td><td>xsd:int</td></tr>
	<tr style="line-height:90%"><td>float, double</td><td>xsd:double</td></tr>
	<tr style="line-height:90%"><td>__int64</td><td>xsd:long</td></tr>
	<tr style="line-height:90%"><td>void</td><td>-</td></tr>
	</table>
	</p>
    }   
}


ad_proc -private soap::check_symbol {
    symbol
} {
    @param symbol
} {
    
    # setup reg expr
    set r {(^[^a-zA-Z]*)([a-zA-Z][a-zA-Z0-9_]*)([^a-zA-Z0-9_]*$)}
    
    # call
    set e [regexp $r $symbol {} a b c]
    
    # test - requiring symbol not to exceed 64 characters ???
    if {
	$e == 0 || 
	[string length $a] > 0 || 
	[string length $b] > 64 ||
	[string length $c] > 0
    } {
	# no good
	soap::fault::raise "Invalid symbol: '$symbol'"
    }
}


ad_proc -private soap::service_from_uri {
    uri
} {
    @author William Byrne
} {
	
    # expects format similar to that returned 
    # from soap::wsdl::build_namespace_uri
	
    # skip protocol scheme
    set offset [string first {://} $uri]
	
    # found ?
    if { $offset >= 0 } {
	# strip scheme
	set uri [string range $uri [expr $offset + 3] end]
    }
    
    # split sub domains and return first
    return [llindex [split $uri .] 0]
}


ad_proc -private soap::get_base_url {
} {
    @author William Byrne
} {

    # calc href base
    set base [ad_conn package_url]

    # verify we're in a soap-gateway site
    if { ![string equal [ad_conn package_key] "soap-gateway"] } {
	# force to apm registration
	set base [apm_package_url_from_key soap-gateway]
    }
	
    # test for problems
    if { $base == {} } {
	# force to install mode
	set base {/soap/}
    }

    # return it
    return $base
}


ad_proc -private soap::get_doc_elements {
    {-service {}}
    proc
} {
    @param proc
} {
    # test for service arg
    if { $service != {} } {
	# build full path
	set proc [format "::sg::%s::%s" $service $proc]
    }
    
    # try and get elements
    if [catch {
	# try
	set elements [nsv_get api_proc_doc $proc]
    }] {
	# failed - strip off leading namespace qualifier
	set elements [nsv_get api_proc_doc [string range $proc 2 end]]
    }

    # return elements
    return $elements
}


ad_proc -private soap::get_source_procs {
    {-private 0}
    {-local 0}
    service
} {
    Returns a list of procedures within the tcl namespace
    formulated by sg::<service>::*

    @param service
} {
    # decl unpublished list
    set procs {}

    # safe fetch
    catch {
	# get methods
	set procs [info commands [format "::sg::%s::*" $service]]
    }

    # decl result
    set result {}

    # loop through source procs
    foreach proc $procs {

        # test for public
        set public 0

	# safe
	catch {

	    # get proc doc elements
	    array set doc_elements [nsv_get api_proc_doc \
                [string range $proc 2 end]]

	    # assign
	    set public $doc_elements(public_p)
	}

	# test
	if { $public || $private } {
	    # test for local (no namespace)
	    if [soap::server::lib::true $local] {
		# get last element after ::	
		regexp {([^:]+$)} $proc {} proc
	    }
	    # add to list
	    lappend result $proc
	}
    }

    # return procs
    return $result
}


ad_proc -private soap::get_source_idl {
    proc
} {
    Returns the idl of a procedure. If the procedure exists,
    an attempt is made to return @idl description. If @idl doesn't
    exists, the idl is formulated from the procedures args. If 
    the procedure doesn't exists, an empty value is returned.
    
    @param proc
} {
    # build formal name
    set formal $proc; #[format "::sg::%s::%s" $service $proc]
    
    # verify
    if { [info commands $formal] == {} } {
	# let's return empty string to signal error
	soap::fault::raise "Cannot get idl for invalid procedur: $proc"
    }
    
    # decl idl 
    set idl {}
    
    # safe 
    catch {
	# get the documentenation array	for the method
	array set doc_elements [soap::get_doc_elements $formal]
		
	# get the @idl value and remove curlies via 'join'
	set idl [join $doc_elements(idl)]
    }
    
    # test idl
    if { $idl == {} } {
	
	# build from tcl info
		
	# decl temp
	set args2 {}
	
	# the default idl will always return a string
	# and each arg will be type string
	foreach arg [info args $formal] {
	    
	    # first time
	    if { $args2 == {} } {
		# assign
		set args2 "string $arg"
	    } else {
		# add to 
		append args2 ", string $arg"
	    }
	}
	
	# remove namespace from proc
	set proc [namespace tail $proc]

	# finish
	set idl [format "string %s(%s)" $proc $args2]
    }

    # return whatever we got
    return $idl
}


ad_proc -private soap::get_source_idls {
    service
} {
    Returns a list of idls for public procedures defined
    within the sg::<service>:: namespace.
    
    @see soap::get_source_idl
    @param service
} {
    # get source procs for service
    set procs [soap::get_source_procs $service]
    
    # decl result list
    set result {}
    
    # loop though procs
    foreach proc $procs {
        # get idl for proc
	lappend result [soap::get_source_idl $proc]
    }

    # return list
    return $result
}


ad_proc -private soap::method_get_procs {
    namespace_id
} {
    @param namespace_id
} {
    # init
    set procs {}

    db_foreach select_procs {} { 
	# append method proc
	lappend procs $proc
    }

    # return methods
    return $procs
}


ad_proc -private soap::diff_methods {
    {-same 0}
    service
} {
    Compares the published service methods to those in the source file
    @param service
} {
    # decl unpublished list
    set procs [soap::get_source_procs $service]
    
    # decl published list
    set methods {}
    set idls {}
    
    # get namespace id
    set nid [soap::server::namespace_get_id $service]
    
    # verify
    if { $nid >= 0 } {
	
	# get published method Tcl proc bindings (proc symbol in db);
	set bindings [soap::method_get_procs $nid]	
	
	# and their idls
	set idls [soap::wsdl::method_get_idls $nid]
    }
    
    # decl history list
    set history {}
    
    # decl diff array
    array set diffs {}
    
    # decl short names list for procs
    set shorts {}
    
    # get idl parser expression for method - "C" syntax
    set method_expr [soap::wsdl::get_style_parser_expr C]
    set arg_expr [soap::wsdl::get_style_parser_expr -argpart 1 C]
    
    # decl published list
    set published {}
    
    # duplicate procs as they're duplicated in the WSDL 
    # database - this will ensure
    # every entry in the database is tested. ??? weak
    
    # decl dups
    set dups {}
    
    # scan
    foreach proc $procs {
			 
        # trim proc name
	set short [namespace tail $proc]
			 
	# decl counter
	set count 0

	# get hits in db
	foreach binding $bindings {
	    
	    # compare
	    if [string equal $binding $short] {
		
		# incr counter
		incr count
		
		# test for more than 1
		if { $count > 1 } {
		    
		    # add dup
		    lappend dups $proc
		}
	    }
	}
    }
    
    # update proc list with duplicated db method entries
    foreach dup $dups {
	# add to proc list
	lappend procs $dup
    }
    
    # loop through source procs
    foreach proc $procs {
			 
        # trim proc name
	set short [namespace tail $proc]
	
	# decl found 
	set found {}
	
	# decl diff var
	set diff {}
	
	# get args for source proc (unpublished?)
	set src_idl [soap::get_source_idl $proc]; #[info args $proc]
	
	# decl uargs (unpublished)
	set uargs {}
	
	# invoke regexp to get args
	if [regexp $method_expr $src_idl {} type src_meth argz] {
	    
	    # loop through args
	    foreach arg [split $argz ,] {
		
		# split
		if [regexp $arg_expr $arg {} type name] {
		    
		    # add to list
		    lappend uargs $name
		}
	    }
	} else {
	    # store for check below
	    set src_meth $short
	}
	
	# search published
	foreach binding $bindings idl $idls {
	    
	    # try
	    if [catch {
		
		# test for case sensitive match
		if [string equal $short $binding] {
		    
		    # decl pargs
		    set pargs {}
		    
		    # invoke regexp to get args
		    if [regexp $method_expr $idl {} type method argz] {
			
			# loop through args
			foreach arg [split $argz ,] {
			    
			    # split
			    if [regexp $arg_expr $arg {} type name] {

				# add to list
				lappend pargs $name
			    }
			}
			
			# park idl method name into found - used below
			#set found $meth
		    } else {
			# egats
			continue
		    }
		    
		    # set found indicator
		    set found $method
		    
		    # compare unpublished args against published args
		    
		    # compare
		    if { [llength $uargs] != [llength $pargs] } {
			
			# note difference
			set diff [list $uargs $pargs]
			
		    } else {
			
			# compare arg names
			foreach u $uargs p $pargs {
			    
			    # compare
			    if ![string equal -nocase $u $p] {
				
				# note difference
				set diff [list $uargs $pargs]
				
				# enough to note diff
				break
			    }
			}
		    }

		    # add to published list
		    lappend published $binding

		    # get idx of binding
		    set idx [lsearch $bindings $binding]

		    # remove from db lists
		    set bindings [lreplace $bindings $idx $idx]
		    set idls [lreplace $idls $idx $idx]
		    set methods [lreplace $methods $idx $idx]
		}
	    } msg] {
		
		# show error for diff
		set diff "err $msg"
	    }

	    # test found
	    if { $found != {} } {
		# stop scanning bindings for match - we found it
		break
	    }
	}	

	# found ?
	if { $found != {} } {

	    # upper case found
	    set ufound [string toupper $found]

	    # check for duplicate
	    if { [lsearch $history $ufound] >= 0 } {
		# mark as duplicate
		set diffs($found) [list DUPL $uargs $pargs]
	    } else {
		# differences ?
		if { $diff != {} } { 
		    # append to results list
		    set diffs($found) [list ARGS $uargs $pargs]
		} elseif [soap::server::lib::true $same] {
		    # append procs that are identical - 'same' flag set
		    set diffs($found) [list SAME $uargs $pargs]
		}

		# add to history
		lappend history $ufound
	    }
	} else {

	    # upper case 
	    set found [string toupper $src_meth]

	    # use full proc name to avoid potential clash
	    # with any db methods of same name

	    # check for duplicate
	    if { [lsearch $history $found] >= 0 } {
		# mark as duplicate
		set diffs($proc) [list DUPL $uargs {}]
	    } else {
		# append missing - modify array key to avoid
		# clash with db method of same name
		set diffs($proc) [list UPUB $uargs {}]

		# add to history
		lappend history $found
	    }
	}
    }

    # add remaining bindings
    foreach binding $bindings idl $idls {
	
	# invoke regexp to get args
	if [regexp $method_expr $idl {} type method argz] {

	    # decl pargs
	    set pargs {}

	    # loop through args
	    foreach arg [split $argz ,] {
		# split
		if [regexp $arg_expr $arg {} type name] {
		    # add to list
		    lappend pargs $name
		}				
	    }
	    
	    # append missing
	    set diffs($method) [list ORPH {} $pargs]
	    
	} else {
	    
	    # append error
	    set diffs($binding) [list ERR {} {}]
	}
    }
    
    #return differences
    return [array get diffs]
}


ad_proc -private soap::namespace_check {
    namespace_id
} {
    @param namespace_id
} {
    # exec db
    set exists [db_string namespace_exists {} -default 0]
    
    # test result
    if { $exists == 0 || [string is integer $exists] != 1 } {
	# failed, throw
	soap::fault::raise "invalid namespace id: $namespace_id"
    }
    # valid
}