<master src="@master@">
<property name="context">@context@</property>
<property name="context_bar">@context_bar@</property>
<include src="../toolbar" caption="@caption@">
<p><strong><font size="4" face="Arial, Helvetica, sans-serif"><a name="top"></a>soap-gateway</font></strong> 
</p>
<p>William Byrne / <a href="mailto:WilliamB@ByrneLitho.com">WilliamB@ByrneLitho.com</a></p>
<p>An experimental OpenACS SOAP package that may prove itself useful. </p>
<p>Developed using the following system configuration:</p>
<ul>
  <li>RedHat 7.3</li>
  <li>OpenACS 4.5 (nightly snapshot 10/3/2002) </li>
  <li>AOLServer 3.3ad13</li>
  <li>nsxml 1.4 </li>
  <li>PostgreSQL 7.2.1</li>
</ul>
<p class="section"></p>
<p><u><strong><a name="abstract"></a><span class="section">Abstract </span></strong></u></p>
<p class="text">The soap-gateway is a compilation of server side tcl procedures 
  and pages that provide Remote Procedure Call (RPC) capabilities to OpenACS servers 
  for clients using SOAP/HTTP. The implementation is relatively small and maintains 
  minimal conformity to current SOAP specifications. This document describes the 
  basic implementation.</p>
<p class="section"><u><a name="toc"></a>Table of Contents</u></p>
<ol>
  <li><a href="#Overview">Overview</a></li>
  <li><a href="#Installation">Installation</a></li>
  <li><a href="#Samples" title="Table of Contents">Samples</a></li>
  <li><a href="#References">References</a></li>
  <li><a href="#License">License</a></li>
</ol>
<p><a name="Overview" class="section"><u>Overview</u></a> <a href="#TOC" title="Table of Contents">(toc)</a></p>
<p>The Simple Object Access Protocol (<a href="#SOAPv12">SOAP</a>) <a href="#SOAPv11">v1.1</a> 
  was <a href="#SOAPSubmission">submitted</a> to W3C on April 18, 2000. Its compatriot 
  Web Services Description Language (<a href="#WSDLv11">WSDL</a>) was <a href="#WSDLSubmission">submitted</a> 
  on March 14, 2001. Together they attempt to unify diverse systems using a form 
  of XML RPC. Most major software vendors are involved to some extent. Its future 
  looks bright. </p>
<p>SOAP fits nicely into the Client/Server topology. Given a client that needs 
  some functionality available on a server, SOAP can be used to specify an operation 
  and its arguments to be submitted by the client to the server. At it's root, 
  the data representing the operation is fairly basic. If the connection between 
  the client and server were a TCP wire, a data trace would show about a page 
  of XML. The XML is not complex and is often decipherable at a glance. The XML 
  data is specified as a <a href="#SOAPv11">SOAP Envelope</a>. An evolving <a href="#SOAPv12">SOAP 
  specification</a> defines the Envelope and its progeny. The XML data transmitted 
  between the client and server is not arbitrary and should conform to a referenced 
  WSDL instance published by the server. It's the WSDL that defines the published 
  services and the invocation formats required for execution. The vast majority 
  of SOAP documentation demonstrates SOAP over HTTP. Another mentioned transport 
  is SMTP. In each case, the SOAP Envelope follows the respective header as an 
  XML Payload.</p>
<p>Many web servers have been retrofitted to support a SOAP subsystem; e.g., Websphere, 
  Apache, iPlanet, IIS, etc. There are a handful of SOAP toolkits. To name a few, 
  <a href="#MSSOAP">MSSOAP Toolkit</a> from Microsoft, <a href="#Axis">AXIS</a> 
  from Apache, and <a href="#DataSnap">DataSnap</a> from Borland. A stand alone 
  Tcl implementation, <a href="#TclSOAP">TclSOAP,</a> is available at Source Forge. 
  In the <a href="#Implementation">Implementation</a> section, I'll get into the 
  details of my retrofit for OpenACS; the soap-gateway package. Client SOAP examples 
  using MSSOAP and AXIS can be found in the <a href="#Samples">Samples</a> section.</p>
<p><a name="Installation" id="Installation"></a><u><span class="section">Installation</span></u> 
  <a href="#TOC" title="Table of Contents">(toc)</a></p>
<p class="text">Here's a short list of steps required to enable SOAP/HTTP connectivity 
  to your server. The instructions are brief and assumes the reader has 
  administrative experience with OpenACS. More details will be available in 
  a subsequent release.</p>
<ol>
  <li>Select the SOAP Gateway from the list of packages that are available for 
	installation. Install it.</li>
  <li>Create a sub-site under the Main site and call it 'soap'. </li>
  <li>Create a new application by selecting the SOAP Gateway.</li>
  <li>For now, call the new soap-gateway application SOAP Gateway. </li>
  <li>Refresh this page so <a href="@base@admin" title="Adminitration">this admin 
	hot link</a> points to the soap-gateway admininistration pages.</li>
  <li>Under the Maintenance section, you should see unpublished services: 'workspace' 
	and 'interop'. Import both.</li>
  <li>In the same section, you may see a message that indicates 'Registered Users' 
	do not have 'invoke' access on the soap-gateway package. If so, go to the 
	<a href="@permissions@" title="Permissions">permissions</a> area for the soap-gateway 
	instance if you wish to grant 'invoke' rights to registered users.</li>
  <li>Go to the <a href="#Samples">Samples</a> section and try the test samples. 
	Take note of the https warning when https'ing.</li>
</ol>
<p><strong>Note:</strong> Verify 'public' access to your installed 'soap-gateway' 
  using <em>http</em> and not <em>https</em>. Select the <a href="@base@">home</a> 
  of your 'soap-gateway' subsite to retrieve a listing of available services. 
  Also verify the WSDL for each service can be returned without the need to authenticate 
  into your server. This will allow clients to enumerate the published services 
  and retrieve the functional specification for each. Eliminating the need to 
  authenticate with the server for the purpose of retrieving service WSDLs removes 
  binding complications for client side SOAP tools.</p>
<p>When importing a tcl library into the soap-gateway (i.e., any public methods 
  under the ::sg::&lt;my-service&gt; namespace), the soap-gateway automatically 
  grants public 'invoke' rights to any method named 'login'. This gives the client 
  an opportunity to authenticate into the server before making any other calls.</p>
<p>Service libraries shipped with the soap-gateway are located in <em>packages/soap-gateway/lib</em>.</p>
<p><a name="Samples"><u class="section">Samples</u></a> <a href="#TOC" title="Table of Contents">(toc)</a></p>
<p>Sample SOAP client applications can be found <a href="@base@tests">here</a>. </p>
<p><a name="References" class="section"><u>References</u></a> <a href="#TOC" title="Table of Contents">(toc)</a></p>
<ul>
  <li><a name="SOAPSubmission"></a>Simple Object Access Protocol (SOAP) Submission 
    <a href="http://www.w3.org/Submission/2000/05/" title="SOAP Submission" target="_blank">http://www.w3.org/Submission/2000/05/</a></li>
  <li><a name="WSDLSubmission"></a>Web Services Description Language (WSDL) Submission 
    <a href="http://www.w3.org/Submission/2001/07/" title="WSDL Submission" target="_blank">http://www.w3.org/Submission/2001/07/</a></li>
  <li><a name="SOAPv11"></a>SOAP v1.1 <a href="http://www.w3.org/TR/SOAP/" title="SOAP v1.1" target="_blank">http://www.w3.org/TR/SOAP/</a></li>
  <li><a name="SOAPv12"></a>SOAP v1.2 Message Framework <a href="http://www.w3.org/TR/soap12-part1/" title="SOAP v1.2 Part 1" target="_blank">http://www.w3.org/TR/soap12-part1/</a></li>
  <li><a name="WSDLv11"></a>WSDL v1.1 <a href="http://www.w3.org/TR/wsdl" title="WSDL v1.1" target="_blank">http://www.w3.org/TR/wsdl</a></li>
  <li>XML Schema Part 0: Primer <a href="http://www.w3.org/TR/xmlschema-0/" title="XML Schema Part 0" target="_blank">http://www.w3.org/TR/xmlschema-0/</a></li>
  <li>XML Schema Part 1: Structures <a href="http://www.w3.org/TR/xmlschema-1/" title="XML Schema Part 1" target="_blank">http://www.w3.org/TR/xmlschema-1/</a></li>
  <li>XML Schema Part 2: Datatypes <a href="http://www.w3.org/TR/xmlschema-2/" title="XML Schema Part 2" target="_blank">http://www.w3.org/TR/xmlschema-2/</a></li>
  <li><a name="MSSOAP"></a>Microsoft SOAP Toolkit <a href="http://msdn.microsoft.com/soap/" title="MS SOAP Toolkit" target="_blank">http://msdn.microsoft.com/soap/</a></li>
  <li><a name="Axis"></a>Apache AXIS <a href="http://xml.apache.org/axis/" title="Apache AXIS" target="_blank">http://xml.apache.org/axis/</a></li>
  <li><a name="DataSnap">Borland DataSnap</a> <a href="http://www.borland.com/delphi/dsnap/index.html" title="Borland DataSnap">http://www.borland.com/delphi/dsnap/index.html</a></li>
  <li><a name="TclSOAP">TclSOAP </a><a href="http://tclsoap.sourceforge.net/" title="TclSOAP" target="_blank">http://tclsoap.sourceforge.net/</a></li>
</ul>
<p><a name="License" class="section" id="License"><u>License</u></a> <a href="#TOC" title="Table of Contents">(toc)</a></p>
<p>The SOAP Gateway package is subject to the <a href="license.txt">Lesser General 
  Public License</a>.</p>
</body>
</html>
