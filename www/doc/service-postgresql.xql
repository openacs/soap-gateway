<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="namespace_select">
    <querytext>
      select service, uri, notes
        from sg_namespaces
	where namespace_id = :nid
    </querytext>
  </fullquery>

  <fullquery name="methods_select">
    <querytext>
      select method_id, namespace_id, method, idl, idl_style, notes 
	from sg_methods
	where namespace_id = :nid
	order by method;
    </querytext>
  </fullquery>

</queryset>