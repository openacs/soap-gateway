ad_page_contract {

  @author WilliamB@ByrneLitho.com
  @creation-date 2002-12-23
  @cvs-id $Id$
} {
	{expr {}}
}

template::form create debug_form

# build service input field
template::element create debug_form expr \
	-widget textarea \
    -datatype text \
    -label "expr" \
    -html { rows 8 cols 80 wrap off } \
    -value $expr

# test for valid form 
if [template::form is_valid debug_form]  {

	if [catch {
		set result [uplevel $expr]
	} msg] { 
		set result $msg 
	}
	
} else {

	set result {}
	
}

ad_return_template


