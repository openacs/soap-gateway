# packages/soap-gateway/www/doc/index.tcl

ad_page_contract {
    
    @author WilliamB@ByrneLitho.com
    @creation-date 2002-12-23
    @cvs-id $Id$
} {
}

# get package id
set package_id [ad_conn package_id]

# require read permission 
ad_require_permission $package_id read

# set context
set context Documentation

# set context bar
set context_bar [ad_context_bar]

# update caption
set caption "help"

# try
if [catch {

    # get href base
    set base [soap::get_base_url]

}] {

    # report as installation error
    error "Failure while calling soap-gateway function!\nDid you restart the server after installing soap-gateway package?\n\n"

}

# get package id
set pid [soap::package_id -throw f]

# set href
set permissions "/permissions/one?object_id=$pid"

# get master
if { 1 || ![string equal [ad_conn package_key] "soap-gateway"] } {

    # ???
    set master "/packages/soap-gateway/www/master"
	
} else {

    # same place as base
    set master "./$base/master"

}

# return template
ad_return_template
