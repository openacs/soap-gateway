<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="soap::server::lib::library_get_paths.select_lib_paths">
    <querytext>
      select path from sg_libraries;
    </querytext>
  </fullquery>

  <fullquery name="soap::server::lib::method_new.method_new">
    <querytext>
      select sg_method__new(
        :namespace_id,
	:method,
	:idl,
	:idl_style,
	:proc,
	:notes,
	now(),
	:user_id,
	:peeraddr,
	:package_id
      );
      </querytext>
</fullquery>

  <fullquery name="soap::server::lib::namespace_new.namespace_new">
    <querytext>
      select sg_namespace__new (
        :service,
        :uri,
	:notes,
	now(),
	:user_id,
	:peeraddr,
	:package_id
	) from dual;
    </querytext>
  </fullquery>

  <fullquery name="namespace_update">      
    <querytext>
      select sg_namespace__update(
        :namespace_id,
	:service,
	:uri,
	:notes,
      ) from dual;
    </querytext>
  </fullquery>

  <fullquery name="soap::server::lib::import_service.namespace_select">      
    <querytext>
      select service, uri, notes 
        from sg_namespaces
	where namespace_id = :nid
    </querytext>
  </fullquery>

  <fullquery name="soap::server::lib::method_update.method_update">      
    <querytext>

    </querytext>
  </fullquery>

  <fullquery name="soap::server::lib::library_new.library_new">      
    <querytext>
        select sg_library__new(:path) from dual
    </querytext>
  </fullquery>

  <fullquery name="soap::server::lib::library_get_path.select_path">      
    <querytext>
      select path
        from sg_libraries
        where library_id = :library_id
    </querytext>
  </fullquery>

  <fullquery name="soap::server::lib::library_delete.delete_library">
    <querytext>
        select 0 + sg_library__delete(:library_id)
    </querytext>
  </fullquery>

  <fullquery name="soap::server::lib::library_update.update_library">      
    <querytext>
        select 0 + sg_library__update(:library_id,:path)
    </querytext>
  </fullquery>

</queryset>