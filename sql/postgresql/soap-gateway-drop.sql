-- packages/soap-gateway/sql/postgresql/soap-gateway-drop.sql
--
-- @author WilliamB@ByrneLitho.com
-- @creation-date 2002-12-22
-- @cvs-id $Id$
--
--

--drop permissions
delete from acs_permissions where object_id in (select method_id from sg_methods);
delete from acs_permissions where object_id in (select namespace_id from sg_namespaces);
delete from acs_permissions where object_id in (select object_id from acs_objects where object_type in ('wsdl_namespace','wsdl_method'));
delete from acs_permissions where object_id in (select package_id from apm_packages where package_key in ('soap-gateway'));

-- clear objects
create function inline_0 ()
returns integer as '
declare
	object_rec		record;
begin
	for object_rec in select object_id from acs_objects where object_type in (''wsdl_namespace'',''wsdl_method'')
	loop
		perform acs_object__delete( object_rec.object_id );
	end loop;

	return 0;
end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

create function inline_2 ()
returns integer as '
declare
	v_invoke varchar;
begin
	select invoke into v_invoke from sg_invoke_moniker;

	-- unbind privileges to global names
	perform acs_privilege__remove_child(''admin'', v_invoke);

	-- drop privileges
	perform acs_privilege__drop_privilege(v_invoke);

	
	return 0;
end;' language 'plpgsql';
select inline_2();
drop function inline_2();


-- drop triggers
drop trigger sg_methods__itrg on sg_methods;
drop trigger sg_methods__dtrg on sg_methods; 
drop trigger sg_methods__utrg on sg_methods; 

-- drop functions
drop function sg_namespace__get_id(varchar);
drop function sg_namespace__new(varchar, varchar, varchar, timestamptz, integer, varchar, integer);
drop function sg_namespace__update(integer, varchar, varchar, varchar);
drop function sg_namespace__exists(integer);
drop function sg_namespace__delete (integer);
drop function sg_method__new(integer, varchar, varchar, varchar, varchar, varchar, timestamptz, integer, varchar, integer);
drop function sg_method__update(integer, varchar, varchar, varchar, varchar, varchar);
drop function sg_method__exists(integer);
drop function sg_method__delete (integer);
drop function sg_namespaces__name (integer);
drop function sg_methods__name (integer);
drop function sg_namespaces__dirty(integer);
drop function sg_methods__itrg();
drop function sg_methods__dtrg();
drop function sg_methods__utrg();
drop function sg_library__new(varchar);
drop function sg_library__update(integer, varchar);
drop function sg_library__delete(integer);
drop function sg_unique(integer,varchar);

-- drop tables
drop table sg_methods;
drop table sg_namespaces;
drop table sg_libraries;

-- drop sequences
drop sequence sg_library_id_seq;

-- drop views
drop view sg_invoke_moniker;

-- drop attributes

-- drop type
select acs_object_type__drop_type(
	   'wsdl_namespace',
	   't'
	);
select acs_object_type__drop_type(
	   'wsdl_method',
	   't'
	);

