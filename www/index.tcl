# packages/soap-gateway/www/index.tcl

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
ad_require_permission $package_id read

# query namespaces
db_multirow -extend {endpoint edit delete wsdl} namespaces namespace_list {} {
    set endpoint [soap::wsdl::build_endpoint $service]
    set edit "edit-namespace?namespace_id=$namespace_id"
    set delete "delete-namespace?namespace_id=$namespace_id"
    set wsdl [soap::wsdl::build_wsdl_url $service]
}

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

# update caption
set caption "services"

ad_return_template
