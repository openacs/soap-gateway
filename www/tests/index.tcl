# packages/soap-gateway/www/tests/index.tcl

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

# set documentation path
set documentation [file join [ad_conn object_url] doc]

# set context
set context "Tests"

# update caption
set caption "tests"

# is this connection secure
if [security::secure_conn_p] {

	# calc http name
	set http [format "http://%s%s"  [ns_info hostname] [file join / [soap::get_base_url] tests]]

}

# return template
ad_return_template

