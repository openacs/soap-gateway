<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="select_method">
    <querytext>
      select method, idl, idl_style, notes 
	from sg_methods
	where method_id = :method_id
    </querytext>
  </fullquery>
</queryset>