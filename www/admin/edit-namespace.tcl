# packages/soap-gateway/www/admin/edit-namespace.tcl

ad_page_contract {

    @author WilliamB@ByrneLitho.com
    @creation-date 2002-12-23
    @cvs-id $Id$
} {
    namespace_id:integer,notnull,optional
    {service ""}
    {notes:html ""}
    method_id:integer,notnull,optional
    {idl ""}
    {proc ""}
    {method_notes:html ""}
    {import 0}
} -properties {
    focus
}

# test for import
if [soap::server::lib::true $import] {

    # test for single method import
    if { $proc != {} } {
	
	# perform single import
	set nid [soap::server::lib::import_service \
		     -proc $proc $service]
	
    } else {
	
	# perform full import
	set nid [soap::server::lib::import_service $service]
		
	# return to admin page
	ad_returnredirect .
		
    }

    # verify args
    if { [info exists namespace_id] != 0 && $nid != $namespace_id } {
	
	# egats
	soap::fault::raise "Namespace id mismatch during import"
	
    } else {
	
	# set id
	set namespace_id $nid
	
    }	
    
}

# clear error
set error {}

# clear focus
set focus {}

# init debug var
set diffdata {}

# get idl help
set idl_help [soap::get_idl_help]

# get package
set package_id [ad_conn package_id]

# check to see if namespace_id is assigned
if {[info exists namespace_id]} {

    # verify namespace id
    soap::namespace_check $namespace_id

    # require write permission
    ad_require_permission $namespace_id admin; #write
	
    # set session context to edit mode
    set context [list "Edit Namespace"]
	
} else {

    # require write permission for new namespace
    ad_require_permission $package_id admin; #create

    # set session context to creation mode
    set context [list "New Namespace"]

}

# create form
template::form create namespace_form

# test for namespace_id assignment
if {[info exists namespace_id]} {

    # set editing 
    set editing_namespace 1

} else {

    # creating 
    set editing_namespace 0

}

# build service input field
template::element create namespace_form service \
    -datatype text \
    -label "Service" \
    -html { size 32 } \
    -value {}; #$service

# build notes input field
template::element create namespace_form notes \
    -widget textarea \
    -datatype text \
    -label "Notes" \
    -html { rows 8 cols 80 wrap off } \
    -value {}; #$notes

# test for valid form 
if [template::form is_valid namespace_form] {

    # clear method_id to disable method logic below
    if [info exists method_id] { unset method_id }
    
    # clean up service
    set service [string trim $service]
	
    # try
    set err [catch {
	    
	# verify
	soap::check_symbol $service

    } error]
	
    # verify
    if { $err } {
	    
	# do nothing
	
    } else {
	
	# get session values	
	set user_id [ad_conn user_id]
	set peeraddr [ad_conn peeraddr]
	
	# force uri to xxxx.openacs.org
	set uri "http://$service.openacs.org/methods"
		
	# look for id of named method
	set nid [soap::server::namespace_get_id $service]
	
	# verify
	if { $nid > 0 && (![info exists namespace_id] || $nid != $namespace_id) } {
		
	    # egats
	    soap::fault::raise "Duplicate service: $service"
	}

	# test for assigned namespace id
	if [info exists namespace_id] {
		
	    # update existing
	    soap::server::lib::namespace_update $namespace_id \
		$service $uri $notes
	    
	} else {
	    
	    # create new
	    soap::server::lib::namespace_new $service $uri $notes $user_id $peeraddr $package_id

	    # return to admin page
	    ad_returnredirect .
			
	}

	# ok return to main list
	#ad_returnredirect "./"
		
    }
    
}

# test for editing
if { $editing_namespace != 0 } {

    # store namespace_id into hidden form element
    template::element create namespace_form namespace_id \
	-widget hidden \
	-datatype text \
	-value $namespace_id

    # query for namespace attributes
    db_1row namespace_select {}

    # update form elements
    template::element set_value namespace_form service $service
    template::element set_value namespace_form notes $notes
    
    # create method form
    template::form create method_form
    
    set method_form:properties(action) edit-namespace
    
    # test for method_id assignment
    if [info exists method_id] {
	
	# set editing 
	set editing_method $method_id
	
    } else {
	
	# creating 
	set editing_method 0
	
    }
	
    # store namespace_id into hidden form element
    template::element create method_form namespace_id \
	-widget hidden \
	-datatype text \
	-value $namespace_id
    
    # build idl input field
    template::element create method_form idl \
	-datatype text \
	-label "IDL" \
	-html { size 48 } \
	-value {}; #$idl
	
    # decl procs
    set procs2 {}
	
    # get source procs and double entries for HTML options
    foreach p [soap::get_source_procs $service] {
		
	# get local
	set local [namespace tail $p]
	
	# append
	lappend procs2 [list "$local {[info args $p]}" $local]
	
    }
    
    # build proc select
    template::element create method_form proc \
	-datatype text \
	-label "Procedure" \
	-widget select \
	-options $procs2 \
	-value $proc
    
    # build notes input field
    template::element create method_form method_notes \
	-widget textarea \
	-datatype text \
	-label "Notes" \
	-html { rows 10 cols 40 wrap off } \
	-value {}; #$notes
    
    # test for valid form 
    if { [template::form is_valid method_form] } {
	
	# try
	set err [catch {
	    
	    # decompose IDL
	    set xsd [soap::server::lib::idl_to_xsd "C" $idl]
	    
	    # get method
	    set method [lindex $xsd 1]
	    
	    # verify
	    soap::check_symbol $method
	    
	} error]
	
	# verify
	if { $err } {
	    
	    # do nothing
	    
	} else {
	    
	    # show
	    set error $xsd
	    
	    # set fixed
	    set idl_style "C"
	    
	    # get session values	
	    set user_id [ad_conn user_id]
	    set peeraddr [ad_conn peeraddr]
	    
	    # look for id of named method
	    set mid [soap::wsdl::method_get_id $namespace_id $method]
	    
	    # verify
	    if { $mid > 0 && $mid != $editing_method } {
		
		# egats
		soap::fault::raise "Duplicate method: $method"
		
	    }
	    
	    # test for assigned method id
	    if { $editing_method != 0 } {
		
		# update existing
		soap::server::lib::method_update $method_id $method $idl $idl_style $proc $method_notes
		
	    } else {
		
		# create new
		soap::server::lib::method_new $namespace_id $method $idl $idl_style $proc $method_notes $user_id $peeraddr $namespace_id
	    }
	    
	    # clear editing mode
	    set editing_method 0
	    
	    #ad_returnredirect "./edit-namespace"
	}
    }

    # get diffs
    array set diffs [soap::diff_methods -same t $service]
	
    if { $editing_method } {
	
	# query for method attributes
	db_1row method_select {}
	
	# store method_id into hidden form element
	template::element create method_form method_id \
	    -widget hidden \
	    -datatype text \
	    -value $method_id
	
	# set db method values into field elements
	template::element set_value method_form idl $idl
	template::element set_value method_form proc $proc
	template::element set_value method_form method_notes $notes
	
    } else {
	
	# clear
	template::element set_value method_form proc {}
	template::element set_value method_form idl {}
	template::element set_value method_form method_notes {}
	
    }
    
    # record history list of db entries
    set history {}
    
    # query methods
    db_multirow -extend {edit delete cancel diff} methods \
	namespace_select_all {} {
	
	# build hot links for edit/delete/...
	set edit "edit-namespace?method_id=$method_id&namespace_id=$namespace_id"
	set delete "delete-method?method_id=$method_id&namespace_id=$namespace_id"
	set cancel "edit-namespace?namespace_id=$namespace_id"
	
	# init diff code
	set diff ERR
	
	# try
	if [catch {
	    
	    # get the diff details for $method
	    set details $diffs($method)
	    
	    # get the diff description code
	    set diff [lindex $details 0]
	    
	    # add entry to history list
	    lappend history $method
	    
	    # get the args
	    set proc [format "$proc {%s}" [lindex $details 1]]
	    
	    # check for orphan
	    if [string equal -nocase -length 4 $diff ORPH] {
		
		# modify proc to reflect orphan
		set proc "#ORPHAN#"
		
	    }
	    
	    
	} msg] {
	    
	    # display error using proc
	    set proc $msg
	    
	}
	
	# use hard spaces
	regsub -all { } $proc {\&nbsp;} proc
	regsub -all { } $idl {\&nbsp;} idl
    }
    
    # debug
    #set diffdata [array get diffs]
    
    # scan history list
    foreach remove $history {
	
	# remove entry from diffs array
	array unset diffs $remove
	
    }
    
    # loop through remaining elements in diffs
    foreach proc [array names diffs] {
				      
        # local 
	set local [namespace tail $proc]
	
	# build import expression
	set import "edit-namespace?namespace_id=$namespace_id&service=$service&import=1&proc=$local"
	
	# get diff code
	set diff [lindex $diffs($proc) 0]
	
	# describe code
	switch $diff {
	    
	    UPUB {
	        set desc {*NOT PUBLISHED*}
	    }
		
	    DUPL {
		set desc {*DUPLICATE IDL*}
	    }
		
	    default {
		set desc {*UNKNOWN ERROR*}
	    }
	    
	}
	
	# get proc
	set local [format "$local {%s}" [lindex $diffs($proc) 1]]
	
	# change to hard spaces
	regsub -all { } $local {\&nbsp;} local
	
	# add to table
	multirow append methods -1 $namespace_id {} $desc {} $local {} $import {} {} $diff
	
    }
    
    # create goto anchor
    set focus "method_form.idl"
    
} else {
    
    # clear
    set editing_method 0
    
    # clear diffs
    array set diffs [list empty {}]
}



# set context
set context "Administration"

# update caption for toolbar
if $editing_namespace {

    # set to edit
    set caption "edit '$service'"
	
    # create namespace var for help
    set namespace [format "::sg::%s" $service]
	
} else {

    # set to create
    set caption "create service"
}

ad_return_template
