# packages/soap-gateway/www/admin/index.tcl

ad_page_contract {

    @author WilliamB@ByrneLitho.com
    @creation-date 2002-12-23
    @cvs-id $Id$
} {
}

# clear title
set title {}

# installed correctly
if [catch {

    soap::server::lib::true 1
	
}] {

    # report as installation error
    error "Failure while calling soap-gateway function!\nDid you restart the server after installing soap-gateway package?\n\n"

}

# get package id
set package_id [ad_conn package_id]

# require read permission 
ad_require_permission $package_id admin

# query namespaces
db_multirow -extend {endpoint edit delete wsdl status} namespaces namespace_list {} {
    set endpoint [soap::wsdl::build_endpoint $service]
    set edit "edit-namespace?namespace_id=$namespace_id"
    set delete "delete-namespace?namespace_id=$namespace_id"
    set wsdl [soap::wsdl::build_wsdl_url $service]
	
    # check for problems
    set diffs [soap::diff_methods $service]
    if { [llength $diffs] > 0 } {
	set status "<font color=\"#CC0000\">errors</font>"
    } else {
	set status "<font color=\"#00CC00\">ok</font>"
    }
}

# get permission for object

# get registered users
set users [acs_magic_object registered_users]

# test for invoke privileges on package for Registered_users
set ru_invoke [soap::server::has_permission -user_id $users $package_id [soap::server::get_invoke_permission_moniker]]

# get public 
set public [acs_magic_object the_public]

# test for public read access on WSDL
set pu_read 1;#[soap::server::has_permission -user_id $public  $package_id read]

# create form
template::form create new_namespace_form

# change action attribute for form - not documented
set new_namespace_form:properties(action) edit-namespace

# create form
template::form create init_workspace_form

# change action attribute for form - not documented
set init_workspace_form:properties(action) init-workspace

# create form
template::form create init_interop_form

# change action attribute for form - not documented
set init_interop_form:properties(action) init-interop

# create unpublished rowset
multirow create unpublished service

# get unpublished
foreach s [soap::query_services -unpublished 1 -published 0] {

    # add to multirow
    multirow append unpublished $s

}

# set context
set context "Administation"

# update caption
set caption "admin"

ad_return_template
