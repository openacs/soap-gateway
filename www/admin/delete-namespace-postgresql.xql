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
</queryset>