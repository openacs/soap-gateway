ad_library {
    Tcl API for a SOAP Server.

    Based on William Byrne's soap-gateway implementation.

    @author William Byrne (WilliamB@ByrneLitho.com)
    @author Nick Carroll (ncarroll@ee.usyd.edu.au)
    @creation-date 2004-09-24
    @cvs-id $Id$
}

namespace eval soap::server {}

ad_proc -public soap::server::get_version_namespace {
    ver
} {
    Returns the namespace for the specified SOAP version.

    @param ver A SOAP version, eg 1.1 or 1.2.
    @return Returns the namespace associated with the specified
    version of SOAP.
} {

    switch $ver {
	1.1 {
	    # Namespace for SOAP 1.1
	    return [parameter::get -parameter "SOAP_NS_1_1"]
	}
	1.2 {
	    # Namespace for SOAP 1.2
	    return [parameter::get -parameter "SOAP_NS_1_2"]
	}
    }

    # return 1.1 as safety
    return [parameter::get -parameter "SOAP_NS_1_1"]
}

ad_proc -public soap::server::get_version_encoding {
    ver
} {
    Returns the encoding for the specified SOAP version.

    @param ver A SOAP version, eg 1.1 or 1.2.
    @return Returns the encoding associated with the specified
    version of SOAP.
} {
    switch $ver {
	1.1 {
	    return [parameter::get -parameter "SOAP_ENC_1_1"]
	}
	1.2 {
	    return [parameter::get -parameter "SOAP_ENC_1_2"]
	}
    }

    # return 1.1 as safety
    return [parameter::get -parameter "SOAP_ENC_1_1"]
}

ad_proc -public soap::server::get_url_params {
} {
    @author William Byrne
} {
    # try to get from target url
    set request [ns_conn request]

    # search for ?
    set offset [string first "?" $request]
	
    # test
    if { $offset >= 0 } {

	# fixup offset
	incr offset
	
	# find first space after query
	set last [string first " " $request $offset]
	
	# fixup
	if { $last < 0 } { 
	    set last end 
	} else { 
	    incr last -1
	}
	
	# get query
	set query [string range $request $offset $last]
		
    } else {
	# clear
	set query {}		
    }
    # return params as ns_set
    return [ns_parsequery $query]
}

ad_proc -public soap::server::get_url_param {
    param
} {
    @author William Byrne
} {
    # get params
    set params [soap::server::get_url_params]

    # return requested
    return [ns_set get $params $param]
}

ad_proc -public soap::server::has_permission {
    {-user_id {}}
    object_id
    privilege
} {
    @param object_id
    @param privilege
} {
    # test user 
    if { $user_id == {} } {
	# set to current user
	set user_id [ad_conn user_id]
    }

    # return permission cache
    return [permission::permission_p -party_id $user_id \
            -object_id $object_id -privilege $privilege]
}

ad_proc -public soap::server::require_permission {
    object_id
    privilege
} {
    @param object_id
    @param privilege
} {
    # check permission cache
    if { ![soap::server::has_permission $object_id $privilege] } {
        # deny
	return [soap::fault::generate_error "Unauthorized: Access Denied"]
    }
}

ad_proc -public soap::server::invoke {
    env
} {
    Take the SOAP request and invoke the method on the server.

    @param env The SOAP envelope sent from the client.
    @return result wrapped in a SOAP response envelope and returned
    to the client.
} {

    # Invoke in safe block
    if {[catch {set result [soap::server::do_invoke $env]} err_msg]} {
	# build fault
	set result [soap::fault::generate_fault $err_msg]
    }

    # return envelope
    return $result
}


ad_proc -private soap::server::do_invoke {
    env
} {
    Parses the specified SOAP envelope for methods, and invokes these
    methods with the supplied arguments.  The results (if any) are
    returned to the invoking client as a SOAP response.

    @param env The SOAP envelope to parse for methods to invoke.
    @return Returns a SOAP response for the invoking client.
} {
    # force to v1.1
    set ver 1.1
        
    # set encoding style  
    set encoding [soap::server::get_version_encoding $ver]

    # set envelope version
    set version [soap::server::get_version_namespace $ver]

    # parse incoming soap envelope
    set doc [dom parse $env] 

    # LOG SOAP Request
    ns_log Notice "\nSOAP Request:\n[$doc asXML]"

    # get doc root
    set root [$doc documentElement]

    # get child nodes of Envelope
    set children [$root childNodes]

    # decl method for response
    set method {}
    set result {}

    # Brute force envelope search is performed in place of 
    # preferred XPath search. I ran into issues that were complicated 
    # by the fact that XPath was not available on a
    # baseline installation. The goal is to demonstrate SOAP interop 
    # and not necessarily write the ideal implementation. Furthermore, 
    # if the envelope exists within XML, it
    # should be found quickly.
    
    # decl mustUnderstand list
    set misunderstood {}
	
    set header [$root selectNodes /SOAP-ENV:Envelope/SOAP-ENV:Header]

    # test for header
    if ![empty_string_p $header] {

	# get requisites
	set reqs [$header childNodes]
	    
	# loop
	foreach r $reqs {
	    
	    # look for must understand
	    set mu [$r getAttribute mustUnderstand]
	    
	    # test 
	    if { $mu == "1" || [string equal -nocase $mu true] } {
		
		# don't understand anything other than 
		# basics right now
		# add to list - should be qnames with namespaces??
		lappend misunderstood [list $r {}]
	    }
	}
    }

    set body [$root selectNodes /SOAP-ENV:Envelope/SOAP-ENV:Body]

    # test for body
    if ![empty_string_p $body] {
	    
	# before proceeding, make sure "misunderstood" var is clear
	if { $misunderstood != {} } {
	    
	    # return misunderstood fault
	    return [soap::fault::generate_misunderstood $misunderstood]
	    
	}
	
	# get methods
	set methods [$body childNodes]
	
	# loop
	foreach m $methods {
	    
	    # get node type
	    set type [$m nodeType]
	    
	    # test for element - skip cdata (axis)
	    if { [string equal -nocase $type "cdata_section"] } {
		# skip 
		continue
	    }
	    
	    # get method namespace
	    set service {};
	    
	    # verify
	    if { $service == {} } {
		# parse connection url and see if it's there
		set service [soap::server::get_url_param service]
	    }
	    
	    # get service/namespace id
	    set nid [soap::server::namespace_get_id $service]
	    
	    # verify
	    if { $nid < 0 } {
		# not found
		return [soap::fault::generate_error "Error: $namespace not found"]
	    }
	    
	    # get method
	    set method [$m nodeName]
	    
	    # authenticate
	    
	    # get method id and proc
	    set id_proc [soap::server::method_get_id_and_proc $nid $method]
	    
	    # get id
	    set mid [lindex $id_proc 0]
	    
	    # get proc
	    set proc [lindex $id_proc 1]
	    
	    # verify
	    if { $mid < 0 } {
		# throw
		set error_msg [format "Invalid service method: '%s:%s'" \
                               $service $method]
		return [soap::fault::generate_error "Error: $error_msg"]
	    }

### Get this working!	    
	    # try authenticating to method
####	    soap::server::require_permission $mid [soap::server::get_invoke_permission_moniker]
	    
	    # build namespace into expr
	    set expr "sg::"
	    
	    # append namespace and proc
	    append expr $service :: $proc
	    
	    # get args
	    set args [$m childNodes]
	    
	    # loop
	    foreach a $args {
		# get node type
		set text_node [$a firstChild]
		lappend expr [$text_node nodeValue]
	    }

	    # invoke - error will be caught by 
	    # caller and returned as fault
	    set result [eval $expr]

	    # done
	    break
	}
    }
    
    return [soap::server::response $version $encoding $method $result]
}

ad_proc -private soap::server::response {
    version
    encoding
    method
    result
} {
    Constructs a SOAP response based on the specified result and method.

    @param version The version of SOAP.
    @param encoding The encoding used for the version of SOAP specified.
    @param method Method name.
    @param result Result to return to the SOAP client.
    @return Returns a SOAP response envelope.
} {
    # construct xml doc object
    set doc [dom createDocument env:Envelope]
    
    # create root node: "env:Envelope"
    set env [$doc documentElement]
    
    # define namespace atts into node
    $env setAttribute xmlns:env $version

    # define encoding style atts into node
    $env setAttribute env:encodingStyle $encoding

    # create SOAP header - "env:Envelope/env:Header"
    set header [$env appendChild [$doc createElement env:Header]]
    
    # create SOAP body - "env:Envelope/env:Body"
    set body [$env appendChild [$doc createElement env:Body]]
        
    # create method node - "env:Envelope/env:Body/?method?"
    set method_node [$body appendChild [$doc createElement [format "m:%s%s" $method Response]]]
    
    # define namespace atts into node
    $method_node setAttribute xmlns:m {http://namespace}; # need real namespace
    
    # create args node - "env:Envelope/env:Body/?method?/?arg?"
    set result_node [$method_node appendChild [$doc createElement Result]]
    set args [$result_node appendChild [$doc createTextNode $result]]

    # LOG SOAP Response
    ns_log Notice "\nSOAP Response:\n[$doc asXML]"

    # render xml into result string
    return [$doc asXML]
}

ad_proc -public soap::server::namespace_get_id {
    service
} {
    @param service The service used to query the namespace id for.
    @return Returns the namespace id for the given service.
} {
    return [db_string namespace_id {} -default -1 ]
}

ad_proc -public soap::server::method_get_id_and_proc {
    namespace_id 
    method
} {
    @param namespace_id
    @param method
    @return Returns the method ID and proc name for the given namespace ID.
} {
    return [db_string method_id_proc {} -default {-1 {}}]
}

ad_proc -private soap::server::get_invoke_permission_moniker {
} {
    @author William Byrne
} {
    # short cut
    return "invoke"

    # eval global within sg namespace
    namespace eval sg {
	# decl moniker
	variable invoke_moniker

	# test for moniker
	if { ![info exists invoke_moniker] } {
	    # get it
	    set invoke_moniker [db_string select_moniker {}]
	}
	
	# return it
	return $invoke_moniker
    }			
}