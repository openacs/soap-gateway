<master src="./master">
<include src="toolbar" caption="@caption@">
<!-- link href="basic.css" rel="stylesheet" type="text/css" -->

<if @namespaces:rowcount@ gt 0>
<a name="top"></a>
<table width="800" border=1 cellpadding=2 cellspacing=2>
  <tr> 
	<td width="118" bgcolor=#cccccc><strong>Service</strong></td>
	<td width="488" bgcolor=#cccccc><strong>Notes</strong></td>
	<td width="54" bgcolor=#cccccc><strong>WSDL</strong></td>
  </tr>
  <multiple name="namespaces" rowcount=1> 
  <tr> 
	<td>
	  <a href="#@namespaces.service@">@namespaces.service@</a>
	</td>
	<td>
	  @namespaces.notes;noquote@&nbsp;
	</td>
	<td><a href="@namespaces.wsdl@">wsdl</a></td>
  </tr>
  </multiple> 
</table>

</if><else>
<p><em>There are no namespaces</em></p>
</else> 
<if @namespaces:rowcount@ gt 0>
<multiple name="namespaces">
<hr size="1" width="800" align="left">
<table width="800" border="0">
  <tr>
	<td width="129"><b><a name="@namespaces.service@"></a>Service:</b></td>
	<td width="636"><b>
	  @namespaces.service@
	  </b>&nbsp;</td>
	<td width="21"><a href="#"><img src="top.gif" width="12" height="12" border="0"></a></td>
  </tr>
  <tr>
	<td><b>Endpoint:</td>
	<td></b><a href="@namespaces.endpoint@">
	  @namespaces.endpoint@
	  </a></td>
	<td>&nbsp;</td>
  </tr>
  <tr>
	<td><b>WSDL:</td>
	<td></b><a href="@namespaces.wsdl@">
	  @namespaces.wsdl@
	  </a></td>
	<td>&nbsp;</td>
  </tr>
  <tr>
	<td>&nbsp;<em>force response:</em></td>
	<td><a href="@namespaces.wsdl@&amp;oneway=0">
	  @namespaces.wsdl@
	  &amp;oneway=0</a></td>
	<td>&nbsp;</td>
  </tr>
  <tr>
	<td>&nbsp;<em>no documentation:</em></td>
	<td><a href="@namespaces.wsdl@&amp;documentation=0">
	  @namespaces.wsdl@
	  &amp;documentation=0</a></td>
	<td>&nbsp;</td>
  </tr>
  <tr>
	<td>&nbsp;<em>trace:</em></td>
	<td><a href="@namespaces.wsdl@&amp;trace=http://localhost:8080">
	  @namespaces.wsdl@
	  &amp;trace=http://localhost:8080</a></td>
	<td>&nbsp;</td>
  </tr>
  <tr>
	<td><b>URI</b></td>
	<td>
	  @namespaces.uri@
	</td>
	<td>&nbsp;</td>
  </tr>
  <tr>
	<td><b>SOAPAction</b></td>
	<td>N/A</td>
	<td>&nbsp;</td>
  </tr>
  <tr>
	<td valign="top"><b>Notes:</td>
	<td></b>
	  @namespaces.notes;noquote@&nbsp;<a href="doc/service?service=@namespaces.service@">(more)</a>
	</td>
	<td>&nbsp;</td>
  </tr>
</table>
</multiple>
</if>


