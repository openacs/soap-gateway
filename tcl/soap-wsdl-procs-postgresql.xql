<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="soap::wsdl::method_get_idls.select_idls">
    <querytext>
      select idl
        from sg_methods
        where namespace_id = :namespace_id
        order by method_id
    </querytext>
  </fullquery>

  <fullquery name="soap::wsdl::method_get_notes.select_notes">
    <querytext>
      select notes
        from sg_methods
        where method_id = :method_id
    </querytext>
  </fullquery>

<fullquery name="soap::wsdl::method_get_id.method_get_id">      
      <querytext>
	select method_id
	  from sg_methods
	  where namespace_id = :namespace_id and
	  lower(method) = lower(:method)
      </querytext>
</fullquery>

<fullquery name="soap::wsdl::method_get_id.method_get_id_with_proc">      
  <querytext>
    select method_id
      from sg_methods
      where namespace_id = :namespace_id and proc = :method
  </querytext>
</fullquery>

<fullquery name="soap::wsdl::namespace_get_notes.select_notes">      
  <querytext>
    select notes
      from sg_namespaces
      where namespace_id = :namespace_id
  </querytext>
</fullquery>

</queryset>