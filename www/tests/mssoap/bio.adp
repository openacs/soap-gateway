<master src="../../master">
<property name="context">@context@</property>
<include src="../../toolbar" caption="@caption@">
<script language="VBScript">
	
	dim Stub
	
	sub window_onload
	
		' clear
		set Stub = Nothing
	
	end sub
	
	sub DoInit
	
		' test 
		if not Stub is Nothing then exit sub

		' Create stub
		set Stub = CreateObject("MSSOAP.SoapClient30")
		
		' specify desired service		
		service = "workspace"

		' get protocol and base location
		base = location.protocol & "//" & location.host
		
		' build wsdl file location
		WsdlFile = base & "/soap/wsdl?service=" & service
		
		' get trace
		trace = document.frm.txtTrace.value
		
		' test
		if trace <> "" then		
		
			' add trace info
		 	WsdlFile = WsdlFile & "&trace=" & trace
			
		end if
		
		' test for oneway disable
		if document.frm.chkOneway.checked then
			
			' add disable flag
			WsdlFile = WsdlFile & "&oneway=0"
			
		end if
		
		' build service namespace
		Namespace = "http://" & service & ".openacs.org/wsdl/"
		
		' initialize stub
		Stub.MSSoapInit2 WsdlFile, "", service, service & "SoapPort", Namespace
		
		' disable
		document.frm.chkOneway.disabled = True
		document.frm.txtTrace.disabled = True
		
	end sub
	
	sub DoLogin

		' init
		DoInit
	
		' get form params
		user = document.frm.txtUser.value
		password = document.frm.txtPassword.value
		
		' invoke
		call Stub.login(user, password)

		' enabled/disable button
		document.frm.btnLogin.disabled = True
		document.frm.btnLogout.disabled = False
		document.frm.txtFirstname.disabled = False
		document.frm.txtLastname.disabled = False
		document.frm.btnUpdate.disabled = False
		
		' get name
		parts = Split(Stub.getName(), " ")
		
		' set first
		document.frm.txtFirstname.value = Trim(parts(0))

		' set last
		if UBound(parts) > 0 then
			document.frm.txtLastname.value = Trim(parts(1))
		end if
		
		
		
	end sub
	
	sub DoLogout
	
		' init
		DoInit

		' invoke
		call Stub.logout()

		' enabled/disable button
		document.frm.btnUpdate.disabled = True
		document.frm.btnLogin.disabled = False
		document.frm.btnLogout.disabled = True
		document.frm.txtFirstname.disabled = True
		document.frm.txtLastname.disabled = True
		document.frm.txtFirstname.value = ""
		document.frm.txtLastname.value = ""
		document.frm.txtPassword.value = ""
		
	end sub
	
	sub DoUpdate

		' init
		DoInit

		' get form params
		firstname = document.frm.txtFirstname.value
		lastname = document.frm.txtLastname.value
		
		' invoke 
		call Stub.setName(firstname, lastname)
		
		' ok
		MsgBox "OK"
		
	end sub
	
</script>
<h3>workspace::setName</h3>
<form name="frm">
  <table width="320" height="114" border="1">
	<tr> 
	  <td align="left"> <input type="text" name="txtUser"> User<br>
	  <input type="password" name="txtPassword"> Password </td>
	</tr>
	<tr> 
	  <td align="center">
	 <input name="btnLogin" type="button" onClick="DoLogin" value="Login" language="VBScript">
		&nbsp;&nbsp; 
		<input name="btnLogout" type="button" disabled="true" onClick="DoLogout" value="Logout" language="VBScript">
	  </td>
	</tr>
  </table><br>
  <table width="320" border="1">
	<tr>
	  <td height="61" align="left"> 
		<input name="txtFirstname" type="text" disabled="true" id="txtFirstname">
		First Name<br> 
		<input name="txtLastname" type="text" disabled="true" id="txtLastname">
		Last Name</td>
	</tr>
	<tr>
	  <td height="43" align="center"> 
		<input name="btnUpdate" type="button" disabled="true" id="btnUpdate" onClick="DoUpdate" value="Update" language="VBScript">
	  </td>
	</tr>
  </table>
  <br>
  <table width="320" border="1" bordercolor="#000000">
	<tr> 
	  <td width="100%" bordercolor="#000000">Debug Trace (e.g., http://locahost:8080)<br> <input type="text" name="txtTrace"> 
		<br> <input type="checkbox" name="chkOneway" checked="true">
		Disable one-way's</td>
	</tr>
  </table>
</form>
