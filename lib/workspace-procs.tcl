ad_library {

	The <em>workspace</em> service provides a set of user workspace functions that
	include the ability to log in and out of the OpenACS system. In order to take 
	advantage of session based SOAP RPC, the HTTP transport used by the client must
	support cookies; otherwise, the user will be limited to methods that have 
	<em>invoke</em> privileges on the <em>Public</em> user.

    @author William Byrne (WilliamB@ByrneLitho.com)

}

# set up workspace namespace and exports
namespace eval sg::workspace {

	# remove old procs
	foreach p [info commands ::sg::workspace::*] {
	
		# remove
		rename $p {}
	}


	ad_proc -public login {
		user 
		password
	} {
		Logs the user into OpenACS. The <em>user</em> and <em>password</em> arguments
		correspond to the user/password values specified during user registration. The
		HTTP transport used for the SOAP Envelope must support cookies for session based
		RPC; otherwise, the user will be limited  WSDL functions that expose 'invoke'
		privileges to 'public'.
		
		@author William Byrne
		@idl void Login(string user, string password)
	} {

		# call soap::login procedure
		return [soap::login $user $password]	
	}
	
	ad_proc -public logout {
	} {
		Logs the current user session out of OpenACS.
		
		@author William Byrne
		@idl void Logout()
	} {
		
		# call sg logout
		return [soap::logout]
	}
	
	ad_proc -public set_name {
		firstname
		lastname
	} {
		Changes the <em>firstname</em> and <em>lastname</em> of the user specified during the 'login' operation.		
		
		@author William Byrne
		@idl void SetName(string firstname, string lastname)
	} {
	
		# get user
		set user_id [ad_conn user_id]
	
		# require write permission on user
		soap::server::require_permission $user_id write
		
		# verify args ???
	
		db_dml {} "update persons
		  set first_names = :firstname,
		  last_name = :lastname
		  where person_id = :user_id"
		
	}
	
	ad_proc -public get_name {
	} {
		Returns the first and last name of the user currently logged in.
		
		@author William Byrne
		@idl string GetName()
	} {
	
		# get user
		set user_id [ad_conn user_id]
	
		# require write permission on user
		soap::server::require_permission $user_id read
		
		db_1row  {} {
		  select first_names, last_name, email, 
		  case when url is null then 'http://' else url end as url,
		  screen_name
		  from cc_users 
		  where user_id=:user_id
		}
	
		# return name
		return [string trim "$first_names $last_name"]
		
	}
	
	ad_proc -private has_bio {
		user_id
		{data {}}
	} {
		Utility procedure that returns whether user has bio record
		
		@author William Byrne	
	} {
	
		# grafted from subsite		
		set retval [db_0or1row grab_bio "select attr_value as bio_old
			from acs_attribute_values
			where object_id = :user_id
			and attribute_id =
			  (select attribute_id
			  from acs_attributes
			  where object_type = 'person'
			  and attribute_name = 'bio')"]
			  
		# test
		if { $data != {} } {
		
			# go up one frame
			upvar $data bio

			if [soap::server::lib::true $retval] {
		
				# set it
				set bio $grab_bio
			
			} else {
				
				# clear it
				set bio {}
				
			}
		
		}			  
		
		# return status
		return $retval
	}
	
	ad_proc -public get_bio {
	} {
		Returns the users biography.
		
		@author William Byrne
		@idl string GetBio()
		
	} {
	
		# get user
		set user_id [ad_conn user_id]
	
		# require write permission on user
		soap::server::require_permission $user_id read
		
		# has bio will fill optional data arg with biography
		has_bio $user_id bio
		
		# return bio
		return $bio
		
	}

	ad_proc -public set_bio {
		bio
	} {
		Updates the users biography.
		
		@author William Byrne
		@idl void SetBio(string bio)
		
	} {
	
		# get user
		set user_id [ad_conn user_id]
	
		# require write permission on user
		soap::server::require_permission $user_id read
		
		# verify length
		soap::check_str_len $bio 4000 "Your biography is too long. Please limit it to 4000 characters"
		
		# has bio ?
		if [has_bio $user_id] {
		
			# grafted from subsite - update
			db_dml update_bio "update acs_attribute_values
			set attr_value = :bio
			where object_id = :user_id
			and attribute_id =
				  (select attribute_id
				  from acs_attributes
				  where object_type = 'person'
				  and attribute_name = 'bio')"
		
		
		} else {
		
			# grafted from subsite - insert		
			db_dml insert_bio "insert into acs_attribute_values
			(object_id, attribute_id, attr_value)
			values 
			(:user_id, (select attribute_id
				  from acs_attributes
				  where object_type = 'person'
				  and attribute_name = 'bio'), :bio)"

		}
				
	}
	
}