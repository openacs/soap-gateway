<master src="../master">
<!-- property name="context">@context@</property -->
<include src="../toolbar" caption="@caption@">
<!-- link href="basic.css" rel="stylesheet" type="text/css" -->
<if @namespaces:rowcount@ gt 0>
<a name="top"></a>
<table width="800" border=1 cellpadding=2 cellspacing=2>
  <tr> 
	<td width="91" bgcolor=#cccccc><strong>Service</strong></td>
	<td width="472" bgcolor=#cccccc><strong>Notes</strong></td>
	<td width="50" bgcolor=#cccccc><strong>Status</strong></td>
	<td width="37" bgcolor=#cccccc><strong>Edit</strong></td>
	<td width="47" bgcolor=#cccccc><strong>Delete</strong></td>
	<td width="51" bgcolor=#cccccc><strong>WSDL</strong></td>
  </tr>
  <multiple name="namespaces" rowcount=1> 
  <tr> 
	<td> <a href="#@namespaces.service@">
	  @namespaces.service@
	  </a> </td>
	<td> 
	  @namespaces.notes;noquote@&nbsp;
	</td>
	<td>@namespaces.status;noquote@</td>
	<td><a href="@namespaces.edit@">edit</a></td>
	<td><a href="@namespaces.delete@">delete</a></td>
	<td><a href="@namespaces.wsdl@">wsdl</a></td>
  </tr>
  </multiple> 
</table>

</if><else>
<p><em>There are no namespaces</em></p>
</else> 
<hr>
<p><strong><u>Maintenance</u></strong></p>
<ul>
  <li><a href="libraries">Manage source libraries</a>.</li>
  <!-- li><a href="edit-namespace">Create new namespace</a></li -->
<if @unpublished:rowcount@ gt 0>
  <multiple name="unpublished" rowcount=0> 
  <li>Import the following unpublished service: <a href="edit-namespace?service=@unpublished.service@&import=1">@unpublished.service@</a></li>
  </multiple>
</if>
<if @ru_invoke@ eq 0>
<b><em><font color="#FF0000"><li>
Registered Users do not have 'invoke' privileges on the soap-gateway package! Go to Permissions.
</li></font></em></b>
</if> 
<if @pu_read@ eq 0>
<b><em><font color="#FF0000"><li>
The Public do not have 'read' privileges on the soap-gateway package! This may restrict clients from downloading WSDL service specifications. Go to Permissions.
</if> 
</li></font></em></b>
</ul>
<p>Note: Only public procedures within the sg::&lt;my-namespace&gt;::* will be 
  imported. Comments are extracted<br>
  from the source files and can modified once imported.</p>

<if @namespaces:rowcount@ gt 0> <multiple name="namespaces"> 
<hr size="1" width="800" align="left">
<table width="800" border="0">
  <tr>
	<td width="129"><b><a name="@namespaces.service@"></a>Service:</b></td>
	<td width="636"><b>
	  @namespaces.service@
	  </b>&nbsp;</td>
	<td width="21"><a href="#"><img src="../top.gif" width="12" height="12" border="0"></a></td>
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
	  @namespaces.notes;noquote@&nbsp;<a href="../doc/service?service=@namespaces.service@">(more)</a>
	</td>
	<td>&nbsp;</td>
  </tr>
</table>
</multiple>
</if>
