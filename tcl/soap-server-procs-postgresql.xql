<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="soap::server::namespace_get_id.namespace_id">
    <querytext>
      select sg_namespace__get_id(:service) from dual
    </querytext>
  </fullquery>

  <fullquery name="soap::server::service_name_exists_p.service_name">
    <querytext>
      select sg_namespace__get_id(:service) from dual
    </querytext>
  </fullquery>

  <fullquery name="soap::server::method_get_id_and_proc.method_id_proc">
    <querytext>
      select method_id || ' ' || proc
        from sg_methods
	where namespace_id = :namespace_id and
	lower(method) = lower(:method)
    </querytext>
  </fullquery>

  <fullquery name="soap::server::get_invoke_permission_moniker.select_moniker">
    <querytext>
      select * from sg_invoke_moniker
    </querytext>
  </fullquery>
</queryset>