ad_library {

    soap-gateway interop routines

    @author William Byrne (WilliamB@ByrneLitho.com)

}

# set up interop namespace
namespace eval sg::interop {

	# remove old procs
	foreach p [info commands ::sg::interop::*] {
	
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
	
		# call sg library
		return [soap::login $user $password]
	}
	
	ad_proc -public logout {
	} {
		Logs the current user session out of OpenACS.
		
		@author William Byrne
		@idl void Logout()
	} {
		# call sg library
		return [soap::logout]
	}
	
	ad_proc -public echo_string {
		data
	} {
		@author William Byrne
		@idl string EchoString(string data)
	} {
	
		# return test data
		return $data
	
	}
	
	ad_proc -public echo_integer {
		data
	} {
		@author William Byrne
		@idl int EchoInteger(int data)
	} {
	
		# return test data
		return $data
	
	}
	
	ad_proc -public echo_float {
		data
	} {
		@author William Byrne
		@idl float EchoFloat(float data)
	} {
	
		# return test data
		return $data
	
	}

	ad_proc -public echo_long {
		data
	} {
		@author William Byrne
		@idl long EchoLong(long data)
	} {
		# return test data
		return $data
	
	}
	
	ad_proc -public echo_int64 {
		data
	} {
		@author William Byrne
		@idl __int64 EchoInt64(__int64 data)
	} {
		# return test data
		return $data
	
	}

	ad_proc -public echo_void {
	} {
		@author William Byrne
		@idl void EchoVoid()
	} {
	
		# return nothing
	
	}

}	
