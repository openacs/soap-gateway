<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="soap::method_get_procs.select_procs">
    <querytext>
      select proc
        from sg_methods
        where namespace_id = :namespace_id
        order by method_id
    </querytext>
  </fullquery>

  <fullquery name="soap::namespace_get_names.select_services">
    <querytext>
      select service from sg_namespaces;
    </querytext>
  </fullquery>

  <fullquery name="soap::package_id.select_pid">
    <querytext>
      select package_id from apm_packages where package_key = 'soap-gateway'
    </querytext>
  </fullquery>

  <fullquery name="soap::namespace_check.namespace_exists">
    <querytext>
      select sg_namespace__exists(:namespace_id);
    </querytext>
  </fullquery>

  <fullquery name="soap::method_check.method_exists">
    <querytext>
        select sg_method__exists(:method_id)
    </querytext>
  </fullquery>

  <fullquery name="soap::namespace_delete.namespace_delete">      
    <querytext>
      select 0 + sg_namespace__delete(:namespace_id);
    </querytext>
  </fullquery>

  <fullquery name="soap::method_delete.delete_method">      
    <querytext>
      select 0 + sg_method__delete(:method_id);
    </querytext>
  </fullquery>

</queryset>