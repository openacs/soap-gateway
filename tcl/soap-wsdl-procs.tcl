ad_library {
    Tcl API for generating WSDLs.

    Based on William Byrne's soap-gateway implementation.

    @author William Byrne (WilliamB@ByrneLitho.com)
    @author Nick Carroll (ncarroll@ee.usyd.edu.au)
    @creation-date 2004-09-24
    @cvs-id $Id$
}


namespace eval soap::wsdl {}


ad_proc -private soap::wsdl::build_wsdl_url {
    service
} {
    @param service
} {
		
    # normal	
    set location [ns_conn location]
		
    # build wsdl url 
    set wsdl [file join [ad_conn object_url] wsdl]
	
    # return format
    return [format "%s%s?service=%s" $location $wsdl $service]
}


ad_proc -private soap::wsdl::method_get_idls {
	namespace_id
} {
    @author William Byrne
} {
    # init
    set methods {}

    # loop through methods belonging to namespace ??? XQL
    db_foreach select_idls {} { 
	# append method idl
	lappend methods $idl
    }

    # return methods
    return $methods
}


ad_proc -private soap::wsdl::get_style_parser_expr {
    {-argpart 0}
    {style "C"}
} {
    @author William Byrne
} {
    # switch
    switch $style {
	C {
	    # test for arg expression
	    if $argpart {

		#return {(.+)(\w+) *$}
		return {(\w+\W+)(\w+)}

	    } else {
		
		return {^ *([^ ]+) +([a-zA-Z][a-zA-Z0-9_]*) *\(([^)]*)}	
	    }
        }
        default {
	    # throw
	    soap::fault::raise "Unsupported IDL parse style: $style"
        }
    }
}


ad_proc -public soap::wsdl::method_get_notes {
	method_id 
} {
    @author William Byrne
} {
    return [db_string select_notes {} -default -1 ]	
}


ad_proc -public soap::wsdl::method_get_id {
	{-proc 0}
	namespace_id 
	method
} {
    @author William Byrne
} {
    # test for 'proc' clause
    if [soap::server::lib::true $proc] {
	set id [db_string method_get_id_with_proc {} -default -1 ]
    } else {
	set id [db_string method_get_id {} -default -1 ]	
    }

    # return
    return $id
}


ad_proc -private soap::wsdl::build_namespace_uri {
    service
} {
    @author William Byrne
} {
    # basic uri
    return "http://$service.openacs.org/message/"
}


ad_proc -public soap::wsdl::namespace_get_notes {
	namespace_id 
} {
    @param namespace_id
} {
    return [db_string select_notes {} -default -1 ]	
}


ad_proc -private soap::wsdl::map_ctype_to_xtype {
    type
} {
    @param type
} {
    
    # strip whitespace
    regsub -all { } $type {} typ
    
    # map type 
    switch $typ {
	
	char -
	wchar_t {
	    # simple character type
	    return [list xsd:string]
	}

	int -
	long {
	    # simpl int
	    return [list xsd:int]
	}
	
	float -
	double {
	    # simple floating point
	    return [list xsd:double]
	}
	
	__int64 {
	    # simple long long
	    return [list xsd:long]
	}
	
	char[] -
	wchar_t[] -
	string - 
	wstring {
	    # string (keep simple)
	    return [list xsd:string]
	}
	
	int[] -
	long[] {
	    # array of ints
	    return [list xsd:int *]
	} 
	
	float[] -
	double[] {
	    # array of floating point
	    return [list xsd:double *]
	}
	
	__int64[] {
	    # array long long
	    return [list xsd:long *]
	}

	void { 
	    # void type
	    return [list]
	}		
    }
    
    # not supported
    soap::fault::unsupported "unable to map $type to xml type - '$type' refined to '$typ'"    
}


ad_proc -private soap::wsdl::build_endpoint {
    service
    {trace {}}
} {
    @param service
    @param trace
} {
    # test for trace
    if { $trace != {} } {
	# use trace info specified in call
	set location $trace
    } else {
	# normal	
	set location [ns_conn location]
    }

    # build action url 
    set action [file join [ad_conn object_url] action]

    # return format
    return [format "%s%s?service=%s" $location $action $service]
}


ad_proc -private soap::wsdl::do_generate_wsdl {
    namespace
    documentation
    oneway
    trace
} {
    @author William Byrne
} {

    # get namespace id
    set nid [soap::server::namespace_get_id $namespace]
	
    # verify
    if { $nid < 0 } {
	
	# not found
	soap::fault::raise "service '$namespace' not found" 404
	
    }
	
    # fixup documentation boolean
    set documentation [soap::server::lib::true $documentation]

    # authenticate
    # ??? soap::server::require_permission $nid read

    # force to v1.1
    set ver 1.1

    # set encoding style
    set encoding [soap::server::get_version_encoding $ver]

    # get methods for namespace
    set funcs [soap::wsdl::method_get_idls $nid]
	
    # decl methods
    set methods {}
	
    # set up regexp expression for "C" style function 
    set expr [soap::wsdl::get_style_parser_expr C]
    #set expr {^ *([^ ]+) +([a-zA-Z0-9_]+) *\(([^)]*)}
	
    # loop through functions
    foreach func $funcs {
	
	# invoke regexp
	regexp $expr $func {} type method argz
	
	# add func to methods list0
	lappend methods $method
	
	# store funcs
	set method_funcs($method) $argz
	
	# store func type
	set method_types($method) $type
	
	# store args
	set method_args($method) [split $argz ,]
	
	# get notes
	if $documentation {
	    set method_notes($method) [soap::wsdl::method_get_notes \
                [soap::wsdl::method_get_id $nid $method]]
	}	
    }

    # construct wsdl doc object
    set doc [dom createDocument definitions]

    # create root WSDL node: "definitions"
    set defs [$doc documentElement] 

    # build namespace uri for methods
    set nsuri [soap::wsdl::build_namespace_uri $namespace]

    # define namespace atts into "definitions" node
    $defs setAttribute name $namespace
    $defs setAttribute targetNamespace "http://$namespace.openacs.org/wsdl/" 
    $defs setAttribute xmlns:wsdlns "http://$namespace.openacs.org/wsdl/" 
    $defs setAttribute xmlns:typens "http://$namespace.openacs.org/type" 
    $defs setAttribute xmlns:soap "http://schemas.xmlsoap.org/wsdl/soap/" 
    $defs setAttribute xmlns:xsd "http://www.w3.org/2001/XMLSchema" 
    $defs setAttribute xmlns "http://schemas.xmlsoap.org/wsdl/"
    
    # add documentation
    if $documentation {
	# get notes for namespace
	set notes [soap::wsdl::namespace_get_notes $nid]
	
	# create child "definitions/documentation" node (allow empty notes)
	set doc_node [$defs appendChild [$doc createElement documentation]]
	set docu [$doc_node appendChild [$doc createTextNode $notes]]
    }
    
    # create child "definitions/types" node
    set types [$defs appendChild [$doc createElement types]]

    # create child "definitions/types/schema" node
    set schema [$types appendChild [$doc createElement schema]]
    
    # define namespace atts into "definitions/types/schema" node
    $schema setAttribute targetNamespace "http://$namespace.openacs.org/type" 
    $schema setAttribute xmlns "http://www.w3.org/2001/XMLSchema" 
    $schema setAttribute xmlns:enc $encoding 
    $schema setAttribute xmlns:wsdl "http://schemas.xmlsoap.org/wsdl/" 
    $schema setAttribute elementFormDefault "qualified"
    
    # loop through decomposed methods
    foreach m $methods {
	
	# get args
	set argz $method_args($m)
	
	# create "definitions/message" node
	set message [$defs appendChild [$doc createElement message]]
	
	# add name attr
	$message setAttribute name "$namespace.$m"
	
	# add documentation
	if $documentation {

	    # create child "definitions/message/documentation" node
	    # (allow empty notes)
	    set doc_node [$message appendChild [$doc createElement documentation]]
	    set docu [$doc_node appendChild [$doc createTextNode $method_notes($m)]]
	}
	
	# decl param order arg
	set order ""
	
	# get arg part parser expr		
	set expr [soap::wsdl::get_style_parser_expr -argpart 1 C]
	
	# loop through args
	foreach a $argz {
	    
	    # split arg type from its name
	    if ![regexp $expr $a {} typ nam] {
		
		# format problem
		error "unexpected argument format: '$a' in '$argz', '$m', '$method_args($m)'"
		
	    }
	    
	    # add arg to param order var
	    lappend order $nam
	    
	    # map type
	    set xtype [soap::wsdl::map_ctype_to_xtype $typ]
	    
	    # get component count
	    set cnt [llength $xtype]
	    
	    # test for simple
	    if { $cnt == 1 } {
		
		# create arg parts
		set part [$message appendChild [$doc createElement part]]
		
		# add name attr
		$part setAttribute name $nam

		# add type attr
		$part setAttribute type [lindex $xtype 0]
		
	    } else {
		
		# not yet supported
		soap::fault::unsupported "cannot spec non simple types: $a, $xtype"
	    }
	}
	
	# reset method_args to hold param order
	set method_args($m) $order
	
	# build return message
	set typ $method_types($m)
	
	# map type
	set xtype [soap::wsdl::map_ctype_to_xtype $typ]
	
	# get component count
	set cnt [llength $xtype]
	
	# test for void
	if { $cnt != 0} {
	    
	    # set boolean into method type for Respond in portType wsdl node
	    set method_types($m) 1
	    
	    # create response message
	    set message [$defs appendChild [$doc createElement message]]
	    
	    # add name attr
	    $message setAttribute name [format "$namespace.$m%s" Response]
	    
	    # test for simple
	    if { $cnt == 1 } {
		
		# create arg parts
		set part [$message appendChild [$doc createElement part]]

		# add name attr
		$part setAttribute name Result
		
		# add type attr
		$part setAttribute type [lindex $xtype 0]
		
	    } else {
		# not yet supported
		soap::fault::unsupported "cannot spec non simple types: $typ"
	    }			
	    
	} elseif { $oneway } {
	    # set false boolean into method type eliminating
	    # Respond in portType wsdl node
	    set method_types($m) 0
	} else {
	    # set true boolean into method type forcing
	    # void Respond in portType wsdl node
	    set method_types($m) 1
	    
	    # create response message
	    set message [$defs appendChild [$doc createElement message]]

	    # add name attr
	    $message setAttribute name [format "$namespace.$m%s" Response]
	    
	    # force string result type
	    if { 1 } {
		
		# create arg parts
		set part [$message appendChild [$doc createElement part]]

		# add name attr
		$part setAttribute name Result
		
		# add type attr
		$part setAttribute type {xsd:string}
	    }
	}
    }
    
    # create portType "definitions/portType" node
    set portType [$defs appendChild [$doc createElement portType]]
    
    # set its name 
    $portType setAttribute name [format "%s%s" $namespace SoapPort]

    # create operations for each function
    foreach m $methods {

	# create new operation
	set operation [$portType appendChild [$doc createElement operation]]
	
	# set its name 
	$operation setAttribute name $m
	
	# set parameter order
	$operation setAttribute parameterOrder $method_args($m)
	
	# create input op
	set input [$operation appendChild [$doc createElement input]]
	
	# bind to message node
	$input setAttribute message [format "wsdlns:%s.%s" $namespace $m]
	
	# test for non void function (false if void)
	if $method_types($m) {
	    
	    # create output op
	    set output [$operation appendChild [$doc createElement output]]
	    
	    # bind to message node
	    $output setAttribute message [format "wsdlns:%s.%s%s" $namespace $m Response]
	}
    }
    
    # setup RPC bindings, encodings, and namespaces
    
    # create binding node - "definitions/binding"
    set binding [$defs appendChild [$doc createElement binding]]
    
    # set its name
    $binding setAttribute name [format "%s%s" $namespace SoapBinding]
    
    # set its type
    $binding setAttribute type [format "wsdlns:%s%s" $namespace SoapPort]
    
    # create child soap binding node 
    set soap_binding [$binding appendChild [$doc createElement soap:binding]]
    
    # set rpc style
    $soap_binding setAttribute style rpc
    
    # set transport
    $soap_binding setAttribute transport {http://schemas.xmlsoap.org/soap/http}
    
    # loop through methods
    foreach m $methods {
	
	# create input child - "definitions/binding/operation"
	set operation [$binding appendChild [$doc createElement operation]]
	
	# set its name
	$operation setAttribute name $m
	
	# create child soap operation node
	# definitions/binding/operation/soap:operation
	set soap_operation [$operation appendChild [$doc createElement soap:operation]]
	
	# set soap action
	$soap_operation setAttribute soapAction [format "http://%s.openacs.org/action/%s.%s" $namespace $namespace $m]
	
	# create child input - "definitions/binding/operation/input"
	set input [$operation appendChild [$doc createElement input]]
	
	# create child soap_body node
	# definitions/binding/operation/input/soap:body
	set soap_body [$input appendChild [$doc createElement soap:body]]
	
	# set 'use' attr
	$soap_body setAttribute use encoded
	
	# set namespace
	$soap_body setAttribute namespace $nsuri
	
	# set encoding
	$soap_body setAttribute encodingStyle $encoding
	
	# test for output
	if $method_types($m) {
	    
	    # create child output - "definitions/binding/operation/output"
	    set output [$operation appendChild [$doc createElement output]]
	    
	    # create child soap_body node
	    # definitions/binding/operation/output/soap:body
	    set soap_body [$output appendChild [$doc createElement soap:body]]
	    
	    # set 'use' attr
	    $soap_body setAttribute use encoded
	    
	    # set namespace
	    $soap_body setAttribute namespace "http://$namespace.openacs.org/message/"
	    
	    # set encoding
	    $soap_body setAttribute encodingStyle $encoding
	}	
    }
    
    # create service 
    
    # create service node - "definitions/service"
    set service [$defs appendChild [$doc createElement service]]
    
    # set its name
    $service setAttribute name $namespace
    
    # create child port - "definitions/service/port"
    set port [$service appendChild [$doc createElement port]]
    
    # set its name
    $port setAttribute name [format "%s%s" $namespace SoapPort]
    
    # set its binding
    $port setAttribute binding [format "wsdlns:%s%s" $namespace SoapBinding]
    
    # create child address - "definitions/service/port/soap:address"
    set soap_address [$port appendChild [$doc createElement soap:address]]
    
    # set its location
    $soap_address setAttribute location [soap::wsdl::build_endpoint $namespace $trace]

    # render xml into string
    return [$doc asXML]
    
}


ad_proc -public soap::wsdl::generate_wsdl {
    {-documentation 1}
    namespace
    {oneway 1}
    {trace {}}
} {
    @author William Byrne
} {
    # fixup and set missing to true
    if { $oneway == {} } { set oneway 1 }

    # try
    if { [catch {

	# delegate to do_generate
	set wsdl [soap::wsdl::do_generate_wsdl $namespace $documentation $oneway $trace]

    } msg] } {
	
	# get error code
	global errorCode
	set code $errorCode

	# normalize error code
	if { ![string is integer $code] } { set code 500 }

	# error
	global errorInfo
	ns_returnerror $code "<pre>$msg\n$errorInfo</pre>"

    } else {

	# return wsdl
	return $wsdl
    }
}