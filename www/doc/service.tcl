# packages/soap-gateway/www/doc/service.tcl

ad_page_contract {

  @author WilliamB@ByrneLitho.com
  @creation-date 2002-12-23
  @cvs-id $Id$
} {
	service:notnull
}

# get package id
set package_id [ad_conn package_id]

# require read permission 
ad_require_permission $package_id read

# get namespace id
set nid [soap::server::namespace_get_id $service]

# check
if { $nid < 0 } {
	# throw
	soap::fault::raise "Invalid service: $service"
}

# query for namespace attributes
db_1row namespace_select {}

# preserve
set service_notes $notes

# query methods
db_multirow -extend {pretty} methods methods_select {} {

	# set up regexp expression for "C" style function 
	set expr [soap::wsdl::get_style_parser_expr C]
	
	# invoke regexp
	regexp $expr $idl {} rtyp meth argz
	
	# get arg parser expr
	set expr [soap::wsdl::get_style_parser_expr -argpart 1 C]
	
	# decl pretty args
	set pargs {}
	
	# loop through args
	foreach a [split $argz ,] {
		
		# split arg type from its name
		if ![regexp $expr $a {} atyp nam] {
		
			# format problem
			error "unexpected argument format: $a"
		
		}
		
		# add arg 
		if { $pargs == {} } {

			# set
			set pargs "<font color=\"blue\">$atyp</font> $nam"
		
		} else {

			# append
			append pargs ", <font color=\"blue\">$atyp</font> $nam"
		
		}
	
	}
	
	# make pretty
	set pretty "<font color=\"blue\">$rtyp</font> <b>$meth</b>($pargs)"

}

# set context
set context [list Documentation]

# update caption
set caption "$service service"

# return template
ad_return_template




