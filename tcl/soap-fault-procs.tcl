ad_library {
    Tcl API for SOAP Faults.

    @author William Byrne (WilliamB@ByrneLitho.com)
    @author Nick Carroll (ncarroll@ee.usyd.edu.au)
    @creation-date 2004-09-24
    @cvs-id $Id$
}


namespace eval soap::fault {}


ad_proc -public soap::fault::assert {
    test
    msg
} {
    @param test
    @param msg
} {
    # calculate
    if [catch {set test [uplevel expr $test] } ] {
	# throw
	soap::fault::raise "Assertion\ntest: $test\n$msg"
    }

    # test
    if { [string is integer -strict $test] == 0 || $test == 0 } {
	# throw
	soap::fault::raise "Assertion\ntest: $test\n$msg"
    }
}


ad_proc -public soap::fault::raise {
    msg
    {code 500}
} {
    @param msg
    @param code Default code set to 500.
} {

    # throw
    error "SOAP Gateway Error\n$msg" {} $code
}


ad_proc -public soap::fault::unauthorized {
    {msg "Access Denied"}
} {
    @param msg
} {

    # throw
    soap::fault::raise "$msg" 401
}


ad_proc -public soap::fault::unsupported {
    msg
} {
    @param msg
} {

    # throw
    soap::fault::raise "$msg" 501
}


ad_proc -private soap::fault::generate_fault {
    msg
    {ver 1.1}
} {
    Generates a fault response based on the specified message.

    @param msg The message to be sent back to the client.
    @param ver The version of SOAP that the message should be based on.
    @return Returns a fault response SOAP message.
} {
    # get version namespace
    set version [soap::server::get_version_namespace $ver]

    # construct xml doc object
    set doc [dom createDocument env:Envelope]

    # create root node: "env:Envelope"
    set env [$doc documentElement] 

    # define namespace atts into node
    $env setAttribute xmlns:env $version

    # create Body node - "env:Envelope/env:Body"
    set body [$env appendChild [$doc createElement env:Body]]

    # create Fault node - "env:Envelope/env:Body/env:Fault"
    set fault [$body appendChild [$doc createElement env:Fault]]
	
    # test version
    if { $ver == "1.1" } {

	# create faultcode node
        # env:Envelope/env:Body/env:Fault/env:faultcode
	$fault appendXML "<env:faultcode>env:Client</env:faultcode>"
	
	# create faultstring node
	# env:Envelope/env:Body/env:Fault/env:faultstring
	$fault appendXML "<env:faultstring>$msg</env:faultstring>"
	
    } else { 
		
	# do v1.2

	# create Code node and Value as a sub node of Code
        # env:Envelope/env:Body/env:Fault/env:Code
	# env:Envelope/env:Body/env:Fault/env:Code/env:Value
	$fault appendXML "
            <env:Code>
                <env:Value>env:Sender</env:Value>
            </env:Code>"
	
	# create Reason node
	# env:Envelope/env:Body/env:Fault/env:Reason
	# define lang attr into Reason node
	$fault appendFromList [list env:Reason {xml:lang en-US} {}]
    }
	
    # render xml into result string
    return [$env asXML]
}

ad_proc -private soap::fault::generate_misunderstood {
    namespaces
    {ver 1.1}
} {
    Generates a misunderstood fault response based on the 
    specified namespaces.

    @param namespaces The message to be sent back to the client.
    @param ver The version of SOAP that the message should be based on.
    @return Returns a misunderstood fault response SOAP message.
} {
    # set envelope version
    set version [soap::server::get_version_namespace $ver]

    # construct xml doc object
    set doc [dom createDocument env:Envelope]

    # create root node: "env:Envelope"
    set env [$doc documentElement]

    # define namespace atts into node
    $env setAttribute xmlns:env $version
    $env setAttribute xmlns:flt http://www.w3.org/2003/05/soap-faults

    # create Header node - "env:Envelope/env:Header"
    set header [$env appendChild [$doc createElement env:Header]]

    # loop through namespaces and add
    foreach ns $namespaces {
        # safety
        if { [llength $ns] > 1 } {
	    # add child
            set mu [$header appendChild [$doc createElement flt:Misunderstood]]

	    # get qname
	    set qname [lindex $ns 0]

	    # split off namespace prefix
	    set parts [split $qname :]

	    # test
	    if { [llength $parts] > 1 } {
		# get prefix
		set prefix [lindex $parts 0]
		
		# get name
		set name [lindex $parts 1]
	    } else {
		# generate prefix
		append auto x

		# set prefix to auto
		set prefix $auto

		# set name to qname
		set name $qname
	    }

	    # add name attr
	    $mu setAttribute qname "$prefix:$name"

	    # add namespace
	    $mu setAttribute "xmlns:$prefix" [lindex $ns 1]
	}
    }

    # create Body node - "env:Envelope/env:Body"
    set body [$env appendChild [$doc createElement env:Body]]

    # create Fault node - "env:Envelope/env:Body/env:Fault"
    set fault [$body appendChild [$doc createElement env:Fault]]

    # test version
    if { $ver == "1.1" } {
	
	# create faaultcode node
        #env:Envelope/env:Body/env:Fault/env:faultcode
	$fault appendXML "<env:faultcode>env:MustUnderstand</env:faultcode>"

	# create faultstring node
	# env:Envelope/env:Body/env:Fault/env:faultstring
	$fault appendXML "<env:faultstring>One or more mandatory headers not understood</env:faultstring>"
	
    } else { 
	
	# do v1.2
	
	# create Code node
	# env:Envelope/env:Body/env:Fault/env:Code
	# env:Envelope/env:Body/env:Fault/env:Code/env:Value
        $fault appendXML "
            <env:Code>
                <env:Value>env:MustUnderstand</env:Value>
            </env:Code>"

	# create Reason node
	# env:Envelope/env:Body/env:Fault/env:Reason
	set reason [$fault appendChild [$doc createElement env:Reason]]

	# define lang attr into Reason node
	$reason setAttribute xml:lang "en-US"

	# set message for env:Reason.
	$reason appendChild [$doc createTextNode "One or more mandatory headers not understood"]
    }
    
    # render xml into result string
    return [$env asXML]
}