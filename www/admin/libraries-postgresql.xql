<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="library_list">
    <querytext>
      select library_id, path from sg_libraries
    </querytext>
  </fullquery>
</queryset>