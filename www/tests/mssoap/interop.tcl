# packages/soap-gateway/www/test/mssoap/interop.tcl

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
set context [list [list .. Tests] {MS SOAP}]

# update caption
set caption "interop test"

# return template
ad_return_template
