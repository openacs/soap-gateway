# packages/soap-gateway/www/admin/delete-namespace.tcl

ad_page_contract {

  @author WilliamB@ByrneLitho.com
  @creation-date 2002-12-23
  @cvs-id $Id$
} {
	namespace_id:integer,notnull
}

# clear title
set title {}

# get package
set package_id [ad_conn package_id]

# verify namespace id
soap::namespace_check $namespace_id

# require admin permission
ad_require_permission $namespace_id admin; #write
	
# set session context to delete mode
set context [list "Administration"]

# create form
template::form create namespace_form

# store namespace_id into hidden form element
template::element create namespace_form namespace_id \
	-widget hidden \
	-datatype text \
	-value $namespace_id

# query for namespace attributes
db_1row namespace_select {}

# test for valid form 
if [template::form is_valid namespace_form] {

	# update existing
	soap::namespace_delete $namespace_id

	ad_returnredirect "./"
}

ad_return_template
