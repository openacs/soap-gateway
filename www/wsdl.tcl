# packages/soap-gateway/www/wsdl.tcl

# clear title
set title {}

# get params from url
set params [soap::server::get_url_params]

# get interested params
set service [ns_set get $params service]
set oneway [ns_set get $params oneway]
set trace [ns_set get $params trace]
set docs [ns_set get $params documentation]
if ![string length $docs] { set docs 1 }

# render xml and return
ns_return 200 text/xml [soap::wsdl::generate_wsdl -documentation $docs $service $oneway $trace] 
 
 