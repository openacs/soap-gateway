# packages/soap-gateway/www/admin/method-namespace.tcl

ad_page_contract {

  @author WilliamB@ByrneLitho.com
  @creation-date 2002-12-23
  @cvs-id $Id$
} {
	namespace_id:integer,notnull
	method_id:integer,notnull
}

# clear title
set title {}

# get package
set package_id [ad_conn package_id]

# verify namespace id
soap::method_check $method_id

# require write permission
ad_require_permission $method_id admin; #write
	
# set session context
set context [list "Administration"]

# create form
template::form create method_form

# store namespace_id into hidden form element
template::element create method_form namespace_id \
	-widget hidden \
	-datatype text \
	-value $namespace_id

# store method_id into hidden form element
template::element create method_form method_id \
	-widget hidden \
	-datatype text \
	-value $method_id

# query for method attributes
db_1row select_method {}

# test for valid form 
if [template::form is_valid method_form] {

	# update existing
	soap::method_delete $method_id

	ad_returnredirect "./edit-namespace?namespace_id=$namespace_id"
}

ad_return_template
