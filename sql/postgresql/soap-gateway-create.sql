-- packages/soap-gateway/sql/postgresql/soap-gateway-create.sql
--
-- @author WilliamB@ByrneLitho.com
-- @creation-date 2002-12-22
-- @cvs-id $Id$
--
--

-- clear existing
--\i soap-gateway-drop.sql
--\q
create function inline_0 ()
returns integer as '
begin
    PERFORM acs_object_type__create_type (
	''wsdl_namespace'',			-- object_type
	''WSDL Namespace'',			-- pretty_name
	''WSDL Namespaces'',		-- pretty_plural
	''acs_object'',				-- supertype
	''sg_namespaces'',			-- table_name
	''namespace_id'',			-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	''sg_namespaces__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_0 ();

drop function inline_0 ();

create function inline_1 ()
returns integer as '
begin
    PERFORM acs_object_type__create_type (
	''wsdl_method'',			-- object_type
	''WSDL Method'',			-- pretty_name
	''WSDL Methods'',			-- pretty_plural
	''acs_object'',				-- supertype
	''sg_methods'',				-- table_name
	''method_id'',				-- id_column
	null,						-- package_name
	''f'',						-- abstract_p
	null,						-- type_extension_table
	''sg_methods__name''		-- name_method
	);

    return 0;
end;' language 'plpgsql';

select inline_1 ();

drop function inline_1 ();

-- define invoke moniker
create view sg_invoke_moniker as
	select 'invoke' as invoke from dual;

create function inline_2 ()
returns integer as '
declare
	v_invoke varchar;
begin
	select invoke into v_invoke from sg_invoke_moniker;

	-- create privileges
	perform acs_privilege__create_privilege(v_invoke);
	
	-- bind privileges to global names
	perform acs_privilege__add_child(''admin'',v_invoke);
	
	return 0;
end;' language 'plpgsql';
select inline_2();
drop function inline_2();



create table sg_namespaces (
    namespace_id    integer 
			   constraint sg_namespaces_namespace_id_fk
			   references acs_objects(object_id) 
			   constraint sg_namespaces_namespace_id_pk
			   primary key,
    service	   varchar(255) 
			   constraint sg_namespaces_service_nn
			   not null unique check(trim(service) <> ''),
    uri		   varchar(255) 
			   constraint sg_namespaces_uri_nn
			   not null,
	dirty	   boolean
			   default 't'
			   constraint sg_namespaces_dirty_nn
			   not null,
    notes      varchar(1024)
);

create index sg_namespaces_idx1 on sg_namespaces(service);

create table sg_methods (
    method_id    integer 
			   constraint sg_methods_method_id_fk
			   references acs_objects(object_id) 
			   constraint sg_methods_namespace_id_pk
			   primary key,
    namespace_id   integer 
			   constraint sg_methods_namespace_id_fk
			   references sg_namespaces(namespace_id),
    method	   varchar(255) 
			   constraint sg_methods_method_nn
			   not null check(trim(method) <> ''),
    idl		   varchar(255) 
			   constraint sg_methods_idl_nn
			   not null,
    idl_style  varchar(32)
			   constraint sg_methods_idl_style_nn
			   not null,
    proc       varchar(255) 
			   constraint sg_methods_proc_nn
			   not null,
    notes      varchar(1024)
);

-- oddity fixup for lower case on index
create function sg_unique(integer,varchar)
returns text as '
begin
	return '''' || $1 || ''-'' || lower($2);
end;' language 'plpgsql' with(iscachable);;


create unique index sg_methods_idx1 on sg_methods(sg_unique(namespace_id, method));

	
create table sg_libraries (
    library_id  integer not null primary key,
	path	varchar(255) not null unique
);

--
-- sequences
--

create sequence sg_library_id_seq start 1000;

--
-- functions
--

-- get namespace id
create function sg_namespace__get_id(varchar)
returns integer as '
declare
	p_service		alias for $1;

	v_namespace_id		sg_namespaces.namespace_id%type;
begin

	-- nullify
	v_namespace_id = null;

	-- get namespace count for id
	select into v_namespace_id namespace_id
	from sg_namespaces
	where service = p_service;
	
	-- fix up
	if v_namespace_id is null then
		v_namespace_id = -1;
	end if;
	
	-- return object id
	return v_namespace_id;

end;' language 'plpgsql';	

-- create new namespace
create function sg_namespace__new(varchar, varchar, varchar, timestamptz, integer, varchar, integer)
returns integer as '
declare
	p_service		alias for $1;
	p_uri			alias for $2;
	p_notes			alias for $3;

	p_creation_date	alias for $4;	-- default now()
	p_creation_user	alias for $5;
	p_creation_ip	alias for $6;
	p_context_id	alias for $7;

	v_namespace_id		sg_namespaces.namespace_id%type;
begin

	-- create new base object
	v_namespace_id := acs_object__new (
		null,
		''wsdl_namespace'',
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	-- add to namespace table
	insert into sg_namespaces
	  (namespace_id, service, uri, dirty, notes)
	values
	  (v_namespace_id, p_service, p_uri, ''t'', p_notes);

	-- create admin permission
	PERFORM acs_permission__grant_permission(
          v_namespace_id,
          p_creation_user,
          ''admin''
    );

	-- return new object id
	return v_namespace_id;

end;' language 'plpgsql';	

create function sg_namespace__update(integer, varchar, varchar, varchar)
returns integer as '
declare
	p_namespace_id	alias for $1;
	p_service		alias for $2;
	p_uri			alias for $3;
	p_notes			alias for $4;

begin

	-- update row values
	update sg_namespaces
		set 
			service = p_service,
			uri = p_uri,
			dirty = ''t'',
			notes = p_notes
		where
			namespace_id = p_namespace_id;
			
	-- return something
	return 0;

end;' language 'plpgsql';	

-- check namespace id
create function sg_namespace__exists(integer)
returns integer as '
declare
	p_namespace_id alias for $1;
	v_record record;
begin
	
	-- get namespace count for id
	select into v_record count(*)
	from sg_namespaces
	where namespace_id = p_namespace_id;
	
	-- test
	return v_record.count;

end;' language 'plpgsql';	

-- remove namespace and child methods
create function sg_namespace__delete (integer)
returns integer as '
declare
	p_namespace_id	alias for $1;
	v_object_rec		record;
begin

	-- verify id
	if sg_namespace__exists(p_namespace_id) = 0 then
		raise EXCEPTION ''Invalid namespace id: %'', p_namespace_id;
	end if;

	-- clean up permissions for namespace methods
	delete from acs_permissions
		where object_id in (
			select method_id from sg_methods
				where namespace_id = p_namespace_id
			);
			
	-- clean up permissions for namespace
    delete from acs_permissions
		where object_id = p_namespace_id;

	-- remove method objects
	for v_object_rec in select method_id from sg_methods where namespace_id = p_namespace_id
	loop
		perform acs_object__delete( v_object_rec.method_id );
	end loop;

	PERFORM acs_object__delete(p_namespace_id);

	-- remove methods
	delete from sg_methods
		where namespace_id = p_namespace_id;
	
	-- remove namespace
	delete from sg_namespaces
		where namespace_id = p_namespace_id;

	return 0;

end;' language 'plpgsql';


-- create new method
create function sg_method__new(integer, varchar, varchar, varchar, varchar, varchar, timestamptz, integer, varchar, integer)
returns integer as '
declare
	p_namespace_id	alias for $1;
	p_method		alias for $2;
	p_idl			alias for $3;
	p_idl_style		alias for $4;
	p_proc			alias for $5;
	p_notes			alias for $6;

	p_creation_date	alias for $7;	-- default now()
	p_creation_user	alias for $8;
	p_creation_ip	alias for $9;
	p_context_id	alias for $10;

	v_method_id		integer;
begin

	-- create new base object
	v_method_id := acs_object__new (
		null,
		''wsdl_method'',
		p_creation_date,
		p_creation_user,
		p_creation_ip,
		p_context_id
	);

	-- add to method table
	insert into sg_methods
	  (method_id, namespace_id, method, idl, idl_style, proc, notes)
	values
	  (v_method_id, p_namespace_id, p_method, p_idl, p_idl_style, p_proc, p_notes);

	-- create admin permission
	PERFORM acs_permission__grant_permission(
          v_method_id,
          p_creation_user,
          ''admin''
    );

	-- return new object id
	return v_method_id;

end;' language 'plpgsql';	

-- update method
create function sg_method__update(integer, varchar, varchar, varchar, varchar, varchar)
returns integer as '
declare
	p_method_id		alias for $1;
	p_method		alias for $2;
	p_idl			alias for $3;
	p_idl_style		alias for $4;
	p_proc			alias for $5;
	p_notes			alias for $6;

begin

	-- update row values
	update sg_methods
		set 
			method = p_method,
			idl = p_idl,
			idl_style = p_idl_style,
			proc = p_proc,
			notes = p_notes
		where
			method_id = p_method_id;
			
	-- return something
	return 0;

end;' language 'plpgsql';	

-- check method id
create function sg_method__exists(integer)
returns integer as '
declare
	p_method_id alias for $1;
	v_record record;
begin
	
	-- get method count for id
	select into v_record count(*)
	from sg_methods
	where method_id = p_method_id;
	
	-- test
	return v_record.count;

end;' language 'plpgsql';	
	
-- remove method
create function sg_method__delete (integer)
returns integer as '
declare
	p_method_id	alias for $1;
begin

	-- verify id
	if sg_method__exists(p_method_id) = 0 then
		raise EXCEPTION ''Invalid method id: %'', p_method_id;
	end if;


	-- clean up permissions for method
    delete from acs_permissions
		where object_id = p_method_id;

	-- remove method object
	perform acs_object__delete(p_method_id);
	
	-- remove methods
	delete from sg_methods
		where method_id = p_method_id;
	
	return 0;

end;' language 'plpgsql';

-- create new library
create function sg_library__new(varchar)
returns integer as '
declare
	p_path			alias for $1;

	v_library_id		sg_libraries.library_id%type;
begin

	-- create next val
	v_library_id = nextval(''sg_library_id_seq'');
	
	-- add to library table
	insert into sg_libraries
	  (library_id, path)
	values
	  (v_library_id, p_path);

	-- return id
	return v_library_id;

end;' language 'plpgsql';	

-- update library
create function sg_library__update(integer, varchar)
returns integer as '
declare
	p_library_id	alias for $1;
	p_path		alias for $2;
begin

	-- update row values
	update sg_libraries
		set 
			path = p_service
		where
			library_id = p_library_id;
			
	-- return something
	return 0;

end;' language 'plpgsql';	

-- remove library
create function sg_library__delete (integer)
returns integer as '
declare
	p_library_id	alias for $1;
begin

	-- remove 
	delete from sg_libraries
		where library_id = p_library_id;

	return 0;

end;' language 'plpgsql';

-- returns namespace name
create function sg_namespaces__name (integer)
returns varchar as '
declare
    id      alias for $1;
    v_name  sg_namespaces.service%TYPE;
begin
	select service into v_name
		from sg_namespaces
		where namespace_id = id;

    return v_name;
end;' language 'plpgsql';

-- returns method name
create function sg_methods__name (integer)
returns varchar as '
declare
    id      alias for $1;
    v_name  sg_methods.method%TYPE;
begin
	select method into v_name
		from sg_methods
		where method_id = id;

    return v_name;
end;' language 'plpgsql';

-- forces namespace to dirty state for WSDL regen
create function sg_namespaces__dirty(integer)
returns integer as '
declare
	id alias for $1;
begin
	update sg_namespaces
	set dirty = ''t''
	where namespace_id = id;
    return 0;
end;' language 'plpgsql';
	
-- trigger functions
create function sg_methods__itrg ()
returns opaque as '
begin
    perform sg_namespaces__dirty(new.namespace_id);
    return new;
end;' language 'plpgsql';

create function sg_methods__dtrg ()
returns opaque as '
begin
    perform sg_namespaces__dirty(old.namespace_id);
    return old;
end;' language 'plpgsql';

create function sg_methods__utrg ()
returns opaque as '
begin
    perform sg_namespaces__dirty(new.namespace_id);
	if new.namespace_id <> old.namespace_id then
	    perform sg_namespacs__dirty(old.namespace_id);
	end if;
    return old;
end;' language 'plpgsql';

-- create triggers
create trigger sg_methods__itrg after insert on sg_methods
for each row execute procedure sg_methods__itrg (); 

create trigger sg_methods__dtrg after delete on sg_methods
for each row execute procedure sg_methods__dtrg (); 

create trigger sg_methods__utrg after update on sg_methods
for each row execute procedure sg_methods__utrg (); 

-- post intallation configuration
select sg_library__new('packages/soap-gateway/lib/workspace-procs.tcl') from dual;
select sg_library__new('packages/soap-gateway/lib/interop-procs.tcl') from dual;


