<master src="../master">
<!-- property name="context">@context@</property -->
<property name="focus">@focus@</property>
<include src="../toolbar" caption="@caption@">
<formtemplate id="namespace_form" style="plain"></formtemplate> 
<hr size="1" width="800" align="left">
<if @editing_namespace@ not eq 0> 
<h3>Methods</h3>
<formtemplate id="method_form">
<table width="980" border=1 cellpadding=2 cellspacing=2>
  <tr> 
	<td width="120" bgcolor=#cccccc><strong>proc</strong></td>
	<td width="240" bgcolor=#cccccc><strong>IDL</strong></td>
	<td width="400" bgcolor=#cccccc><strong>Notes</strong></td>
	<td width="68" bgcolor=#cccccc>&nbsp;</td>
	<td width="55" bgcolor=#cccccc>&nbsp;</td>
  </tr>
  <multiple name="methods"> 
  <if @editing_method@ eq @methods.method_id@>
  <tr> 
	<td valign="top"><formwidget id="proc"></td>
	<td valign="top"> 
	<formwidget id="idl">
	  @idl_help@
    </td>
	<td> 
	  <formwidget id="method_notes">
	</td>
	<td><input type="submit" value="update"><!-- a href="javascript:document.method_form.submit();">update</a --></td>
	<td><a href="@methods.cancel@">cancel</a></td>
  </tr>
  </if><else>
  <if @methods.method_id@ lt 0>
  <tr> 
	<td>
	<font color="#FF0000">
		@methods.proc@
	</font>
	</td>
	<td>
	<font color="#FF0000">
		<a href="#@methods.diff@">@methods.idl@</a>
	</font>
	</td>
	<td> 
	  @methods.notes@&nbsp;
	</td>
	<td><a href="@methods.edit@">import</a></td>
	<td>&nbsp;</td>
  </tr>
  </if><else>
  <tr> 
	<td>
	<if @methods.diff@ not eq "SAME"> 
		<font color="#FF0000">
		<a href="#@methods.diff@">@methods.proc@</a>
		</font>
	</if><else>
		<font color="#000000">
		@methods.proc;noquote@
		</font>
	</else>
	</td>
	<td>
	<if @methods.diff@ not eq "SAME"> 
		<font color="#FF0000">
	</if><else>
		<font color="#000000">
	</else>
		@methods.idl;noquote@
	</font>
	</td>
	<td> 
		@methods.notes;noquote@&nbsp;
	</td>
	<td><a href="@methods.edit@">edit</a></td>
	<td><a href="@methods.delete@">delete</a></td>
  </tr>
  </else>
  </else>
  </multiple> 
  <if @editing_method@ eq 0>
  <tr> 
  	<td valign="top"><formwidget id="proc"></td>
	<td valign="top"> 
	  <formwidget id="idl">@idl_help;noquote@
	</td>
	<td> 
	  <formwidget id="method_notes">
	</td>
	<td><input type="submit" value="create" ><!-- a href="javascript:document.method_form.submit();">create</a --></td>
	<td>&nbsp;</td>
  </tr>
  </if>
</table>
</formtemplate></if> 
<p><if @editing_namespace@ not eq 0>
<h3>Error Descriptions</h3>
<table width="840" border="0">
  <tr>
	<td width="120" valign="top"><a name="UPUB"><strong>Not Published</strong></a></td>
	<td>A public Tcl proc within the <em><strong> 
	  @namespace@
	  </strong></em> namespace exists that is not published . Selecting <em>import </em>will 
	  add the procedure to the WSDL database. The proc will then be available 
	  for public access using the name specified within <strong>ad_proc's </strong> 
	  <em>@idl</em> 
	  parameter. If the <em>@idl</em> parameter is missing, the proc's symbolic name will be used instead.<br>
	</td>
  </tr>
  <tr>
	<td valign="top"><a name="DUPL" id="DUPL"></a><strong>Duplicate IDL</strong></td>
	<td>The soap-gateway's <em>diff</em> algorithm detected a potential duplicate 
	  method name. The calculated IDL name already exists within the WSDL 
	  database for the <em><strong>@namespace@</strong></em> namespace. Or, the IDL name for the Tcl proc was 
	  detected within the list of sibling procs not yet published to the WSDL database.
	   In either case, the Tcl proc cannot be published 
	  until it's IDL name is made unique within the <em><strong>
	  @namespace@
	  </strong></em> namespace.<br>
	</td>
  </tr>
  <tr>
	<td valign="top"><a name="ORPH"><strong>Orphan</strong></a></td>
	<td>A published method exists within the WSDL database that has no corresponding 
	  <em>public</em> Tcl proc in the <em><strong>
	  @namespace@
	  </strong></em> namespace. Either delete the entry or supply a <em>public</em> Tcl proc. 
	  <br>
	</td>
  </tr>
  <tr>
	<td valign="top"><a name="ARGS"><strong>Arguments</strong></a></td>
	<td>A discrepency exists between the arguments of the Tcl proc and the published method in the
	WSDL database. Comparisons are made to the argument names only. No type checking is performed.
	  <br>
	</td>
  </tr>
</table>
</if><else> 
<p><em>There are no methods!</em></p>
</else> 
@diffdata@
