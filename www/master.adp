<master>
<property name="title">@title@</property>
<if @context@ not nil>
	<property name="context">@context@</property>
</if>
<property name="context_bar">@context_bar@</property>
<property name="header_stuff">
@header_stuff@
<style>
.sg_toolbar { 
	font-family: tahoma,verdana,arial,helvetica; 
	font-size: 70%; 
	font-weight: bold; color: #ccccff; 
	text-decoration: none; 
}

.sg_toolbar:hover { 
	color: white; 
	text-decoration: underline;  
}

A.sg_toolbar { 
	color: white; 
}

INPUT.toolbar { 
	font-family: tahoma,verdana,arial,helvetica; 
	font-weight: bold; 
	font-size: 70%; color: black; 
}
  
.summary { 
	font-size: 70%; 
	font-family: verdana,arial,helvetica; 
}

.summary_bold { 
	font-size: 70%; 
	font-family: verdana,arial,helvetica; 
	font-weight: bold; 
}

pre { 
	font-family: Courier; 
	font-size: 10pt; 
}
  
  

.section  {
	font: bold medium Arial;
}

.text {
  font-family: "Times New Roman", Times, serif;
}

.toc {
	list-style-type : inherit;
	list-style : decimal-leading-zero;
}

.tcl-files {
	list-style-image: url(tcl.gif);
}

.adp-file {
	list-style-image: url(www.gif);
}

.html-file {
	list-style-image: url(www.gif);
}

.text-files {
	list-style-image: url(text.gif);
}

.folder-files {
	list-style-image: url(folder.gif);
}

.file-desc {
	width : 320;
}

</style>
</property>
<slave>


