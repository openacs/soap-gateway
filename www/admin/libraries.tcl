# packages/soap-gateway/www/admin/libraries.tcl

ad_page_contract {

    @author WilliamB@ByrneLitho.com
    @creation-date 2002-12-23
    @cvs-id $Id$
    
} {
    library_id:integer,notnull,optional
    {delete 0}
    {path {}}
    {update 0}
    {force 0}
}

# get package id
set package_id [ad_conn package_id]

# require read permission 
ad_require_permission $package_id admin

# clear status
set stat {}

# test for delete
if [soap::server::lib::true $delete] {
    
    # get current
    set current [soap::server::lib::library_get_path $library_id]
    
    # delete
    soap::server::lib::library_delete $library_id
    
    # stop watch
    soap::server::lib::watch -stop 1 $current
    
} elseif { $path != {} } {
    
    # test for update
    if [info exists library_id] {
	
	# get current
	set current [soap::server::lib::library_get_path $library_id]
	
	# stop watch
	soap::server::lib::watch -stop 1 $current
	
	# update
	soap::server::lib::library_update $library_id $path
	
	# update - implicit watch
	soap::server::lib::update_libraries [list $path]
	
    } else {
	
	if [catch {
	    
	    # create new library
	    soap::server::lib::library_new $path
	    
	}] {
	    
	    # report
	    set stat "Error creating new library path:<br>&nbsp;&nbsp;<em>$path</em><br>Possible duplicate."		
	    
	} else {
	    
	    # update - implicit watch
	    soap::server::lib::update_libraries [list $path]
	    
	}
    }    
    
} elseif [soap::server::lib::true $update] {
    
    # get path from id
    set path [soap::server::lib::library_get_path $library_id]
    
    # update
    soap::server::lib::update_libraries [list $path]
    
}

# query namespaces
db_multirow -extend {status remove} libraries library_list {} {
    set remove "libraries?library_id=$library_id&delete=1"
    if ![soap::server::lib::is_library_valid $path] {
	set status "<font color=\"red\">???</font>"
    } elseif [soap::server::lib::is_library_dirty $path] {
	#set status "<font color=\"red\">stale</font>"
	set status "<a href=\"libraries?library_id=$library_id&update=1\" style=\"color: red\">stale</a>"
    } else {
	set status "<font color=\"#00CC00\">ok</font>"
    }
    
}

# clear path
set path {}

# create form
template::form create library_form

# build path input field
template::element create library_form path \
    -datatype text \
    -label "Path" \
    -html { size "100%" } \
    -value {}; 

# set up path
template::element set_value library_form path "packages/<your-package>/lib/<your-source>.tcl"

# set context
set context "Administration"

# update caption
set caption "admin"

# return template
ad_return_template
