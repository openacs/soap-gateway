<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="namespace_list">
    <querytext>
    select namespace_id, service, uri, notes from sg_namespaces
    </querytext>
  </fullquery>
</queryset>