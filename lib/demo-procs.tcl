ad_library {

    soap-gateway demo routines

    @author William Byrne (WilliamB@ByrneLitho.com)

}

# create namespace
namespace eval sg::demo {

	# remove old procs
	foreach p [info commands ::sg::demo::*] {
	
		# remove
		rename $p {}
	}

	# If there are any authentication requirements for a method in a service, add login
	# and logout wrappers for soap::login and soap::logout methods. 
	#
	# This will prevent the SOAP client transport from having to maintain session cookies
	# across multiple client SOAP stubs. For example, a SOAP client can log into OpenACS using
	# the 'workspace' service. Typically, the SOAP client will fetch the WSDL for the service
	# and expose methods to the developer for calling upon methods specified in the WSDL.
	# In the case of the 'workspace' service, the user would call the 'login' method. If 
	# successful, a session cookie is returned to the client and is maintained by the HTTP
	# transport. If the user wishes to use the 'demo' service, another client SOAP stub 
	# would be created referencing the WSDL for the 'demo' service. Since the 'demo' SOAP
	# stub is new, it won't have the session data maintained by the 'workspace' stub. There
	# are certainly ways to share the session data; however, the process of doing so often 
	# turns into a science project.

	# workspace login wrapper
	ad_proc -public login { 
		user
		password
	} {
		@author William Byrnec
		@idl void Login(string user, string password)
	} {
		
		# call sg library
		return [soap::login $user $password]
	}


	# workspace logout wrapper
	ad_proc -public logout {
	} {
		@author William Byrne
		@idl void Logout()
	} {
		# call sg logout 
		return [soap::logout]
	}


	# define calculate method
	ad_proc -public calculate {
		expr
	} {
	
		Performs an evaluation of the expression argument. The method attemps to provide some
		safety by scanning for procedure notation. If detected, an exception is thrown.
		
		@author William Byrne
		@idl string Calculate(string expr)
	} {
		
		# detect proc bracket
		if { [sting first \[ $expr] >= 0 } {
			# throw
			soap::fault::raise "procedure calls within expression are not allowed!"
		}
		
		# calculate
		return [expr $expr]
	
	}


}
