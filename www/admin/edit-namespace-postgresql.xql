<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="namespace_select">
    <querytext>
      select service, uri, notes
        from sg_namespaces
	where namespace_id = :namespace_id
    </querytext>
  </fullquery>

  <fullquery name="namespace_select_all">
    <querytext>
      select method_id, namespace_id, method, idl, idl_style, proc, notes 
	from sg_methods
	where namespace_id = :namespace_id
    </querytext>
  </fullquery>

  <fullquery name="method_select">
    <querytext>
      select method, idl, idl_style, proc, notes 
        from sg_methods
        where method_id = :method_id
    </querytext>
  </fullquery>
</queryset>