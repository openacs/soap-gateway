<master src="../master">
<property name="context">@context@</property>
<include src="../toolbar" caption="@caption@">
<table border="0">
<tr><td width="20"></td><td width="580">
@service_notes@
</td></td>
</table>
<table border="0">

<multiple name="methods"> 
<tr><td width="20"></td><td>
<table width="580" >
<tr style="margin-top: 8px"><td width="600">
<hr size="1">
<font face="Courier New, Courier, mono">
@methods.pretty;noquote@
</font>
</td></tr>
<tr><td>
@methods.notes;noquote@
</td></tr>
</table>
</td></tr>
</multiple> 

</table>