# packages/soap-gateway/www/test/axis/index.tcl

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
set context [list [list .. Tests] {AXIS}]

# update caption
set caption "axis toolkit"

# update references
set references [file join [ad_conn object_url] doc #References]

# return template
ad_return_template
