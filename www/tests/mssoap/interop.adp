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
		service = "interop"

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
		
	end sub
	
	sub DoLogout
	
		' init
		DoInit

		' invoke
		call Stub.logout()

		' enabled/disable button
		
		document.frm.btnLogin.disabled = False
		document.frm.btnLogout.disabled = True
		
	end sub
	
	sub DoEchoString

		' init
		DoInit

		' get form params
		echo = document.frm.txtEchoString.value
		
		' invoke and show results
		MsgBox Stub.echoString(echo)
		
	end sub

	sub DoEchoInteger

		' init
		DoInit

		' get form params
		echo = document.frm.txtEchoInteger.value
		
		' invoke and show results
		MsgBox Stub.echoInteger(echo)
		
	end sub
	
	sub DoEchoFloat

		' init
		DoInit

		' get form params
		echo = document.frm.txtEchoFloat.value
		
		' invoke and show results
		MsgBox Stub.echoFloat(echo)
		
	end sub

	sub DoEchoVoid

		' init
		DoInit

		' get form params
		echo = document.frm.txtEchoVoid.value
		
		' invoke and show results
		Stub.echoVoid
		
	end sub

</script>
<h3>interop::echo* test</h3>
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
  </table>
  <br>
  <table width="320" border="1">
	<tr> 
	  <td width="61">String</td>
	  <td width="161"><input name="txtEchoString" type="text" id="txtEchoString" value="this is an echo"></td>
	  <td width="76" align="center"> 
		<input name="btnEchoString" type="button" id="btnEchoString" onClick="DoEchoString" value="Echo" language="VBScript"> 
	  </td>
	</tr>
	<tr> 
	  <td>Integer</td>
	  <td><input name="txtEchoInteger" type="text" id="txtEchoInteger" value="123456"></td>
	  <td align="center"><input name="btnEchoInteger" type="button" id="btnEchoInteger" onClick="DoEchoInteger" value="Echo" language="VBScript"></td>
	</tr>
	<tr> 
	  <td>Float</td>
	  <td><input name="txtEchoFloat" type="text" id="txtEchoFloat" value="123.45"></td>
	  <td align="center"><input name="btnEchoFloat" type="button" id="btnEchoFloat" onClick="DoEchoFloat" value="Echo" language="VBScript"></td>
	</tr>
	<tr> 
	  <td>Void</td>
	  <td><input name="txtEchoVoid" type="text" id="txtEchoVoid"></td>
	  <td align="center"><input name="btnEchoVoid" type="button" id="btnEchoVoid" onClick="DoEchoVoid" value="Echo" language="VBScript"></td>
	</tr>
  </table>
  <br>
  <br>
  <table width="320" border="1" bordercolor="#000000">
	<tr> 
	  <td width="100%" bordercolor="#000000">Debug Trace (e.g., http://locahost:8080)<br> <input type="text" name="txtTrace"> 
		<br> <input type="checkbox" name="chkOneway" checked="true">
		Disable one-way's</td>
	</tr>
  </table>
</form>
