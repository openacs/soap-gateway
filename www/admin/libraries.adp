<master src="../master"> 
<!-- property name="context">@context@</property -->
<include src="../toolbar" caption="@caption@">
<a name="top"></a> 
<p> Enter the locations of the source files that will be available for importing 
  into the soap-gateway.<br>
  Relative locations will be appended to the <em>acs_root </em>directory. Directory 
  watches will be converted<br>
  to wildcard notation and will not recurse; e.g., soap-gateway/lib/*.tcl. The 
  files are <em>watched</em> by the<br>
  Request Processor. <a href="libraries">Refresh</a> to update status.</p>
<p>Once the source files are loaded, go back to the <a href=".">admin</a> and 
  import the services into the soap-gateway.<br>
</p>
<formtemplate id="library_form"> 
<table width="800" border=1 cellpadding=2 cellspacing=2>
  <tr> 
	<td width="760" bgcolor=#cccccc><strong>Path</strong></td>
	<td width="20" bgcolor=#cccccc><strong>Status</strong></td>
	<td width="20" bgcolor=#cccccc><strong>Watch</strong></td>
  </tr>
  <multiple name="libraries"> 
  <tr> 
	<td> 
	  @libraries.path@</a>
	  </td>
	<td> 
	  @libraries.status;noquote@
	</td>
	<td><a href="@libraries.remove@">remove</a></td>
  </tr>
  </multiple> 
  <tr> 
	<td><formwidget id="path"></a></td>
	<td>&nbsp;</td>
	<td><a href="javascript:document.library_form.submit();">add</a></td>
  </tr>
</table>
</formtemplate><br>
<table width="99%" border="0">
  <tr> 
	<td width="4%">&nbsp;</td>
	<td width="10%"><u><strong>Status</strong></u></td>
	<td width="86%"><u><strong>Meaning</strong></u></td>
  </tr>
  <tr> 
	<td>&nbsp;</td>
	<td><font color="red">???</font></td>
	<td>Library path returned no tcl source files</td>
  </tr>
  <tr> 
	<td>&nbsp;</td>
	<td><font color="#00CC00">ok</font></td>
	<td>All file timestamps in the path spec. coincide with APM</td>
  </tr>
  <tr> 
	<td>&nbsp;</td>
	<td><font color="red">stale</font></td>
	<td>At least one file timestamp in the path spec. does not coincide with APM</td>
  </tr>
</table>
<p>
  @stat@
</p>
