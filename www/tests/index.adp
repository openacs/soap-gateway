<master src="../master">
<property name="context">@context@</property>
<include src="../toolbar" caption="@caption@">
<p><font face="Arial, Helvetica, sans-serif"><strong>Limited interoperability 
  tests</strong></font></p>
<p><a href="mssoap" title="Microsoft SOAP Toolkit">Using Microsoft 
  SOAP Toolkit</a></p>
<p><a href="axis">Using Apache AXIS Toolkit</a></p>
<p>Refer to the <a href="@documentation@">soap-gateway documentation</a> for more 
  information on how to get the SOAP toolkits.</p>
<if @http@ not nil>
<p><em><strong><font color="#FF0000">SSL connections, SOAP/HTTPS, may not work 
  correctly. For testing, try launching the demo's using <a href="@http@">http</a> 
  instead of https. Service Side Certificates need to be trusted by the Client 
  software without the need for user confirmation. In other words, the SOAP toolkits 
  can't handle popup dialogs very well. And we usually get dialogs when the Server's 
  Certificate cannot be chained to a trusted authority. Free certificates are 
  available from freessl.com.</font></strong></em></p>
</if>