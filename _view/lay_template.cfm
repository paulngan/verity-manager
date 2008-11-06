	<cfparam name="TopNavHome" default="">
	<cfparam name="TopNavCollections" default="">
	<cfparam name="TopNavTasks" default="">
	<cfparam name="TopNavSchedule" default="">
	<cfparam name="TopNavSearch" default="">
		
	<cfparam name="SubNavCollections" default="">
	<cfparam name="SubNavDashboard" default="">
	<cfparam name="SubNavAdd" default="">
	<cfparam name="SubNavIndex" default="">
	<cfparam name="SubNavUpdate" default="">
	<cfparam name="SubNavPurge" default="">
	<cfparam name="SubNavDelete" default="">
	<cfparam name="SubNavSearch" default="">
		
	<cfparam name="SubNavTasks" default="">

	<cfoutput>
	<cfif not isdefined("CGI.HTTP_USER_AGENT")>
		<cfabort showerror="No bots allowed">
	</cfif>
	
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
		"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>		
		<title>Verity Manager</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
		<link rel="stylesheet" href="styles/main.css" type="text/css" media="screen" title="no title" charset="utf-8">
		<link rel="stylesheet" type="text/css" href="styles/accordion.css" />
		<cfif FindNoCase("MSIE", CGI.HTTP_USER_AGENT)>
			<link rel="stylesheet" type="text/css" href="styles/ie.css" />
		</cfif>
		<cfset myList = 'app.dashboard,app.collections,app.tasks,app.schedule'>
		<cfif ListFindNoCase(mylist, attributes.fuseaction)>
			<cfset now = 'now'>
			<script type="text/javascript" src="lib/prototype.js"></script>
			<script type="text/javascript" src="lib/effects.js"></script>
			<script type="text/javascript" src="lib/accordion.js"></script>
			<script type="text/javascript" src="lib/code_highlighter.js"></script>
			<script type="text/javascript" src="lib/javascript.js"></script>
			<script type="text/javascript" src="lib/html.js"></script>
			<script type="text/javascript" src="lib/headscript.js"></script>
		</cfif>
	</head>
	<body>						
		<div id="wrap">			
			<!--- LOGO --->
			<div id="logo">
				<h1>Verity Manager</h1>
				<!--- NAVIGATION --->
				<div id="navigation">
					<!--- Added server time display - AGS(RH) - 4/24/08 --->
					<div style="text-align: right; color: ##999999; font-size: 80%;">Current Server Time: #TimeFormat(Now(), "h:mm:ss tt")#</div>
					<ul>
						<li><a class="#TopNavHome#" href="index.cfm">Home</a></li>
						<li><a class="#TopNavCollections#" href="index.cfm?fuseaction=app.collections">Collections</a></li>
						<li><a class="#TopNavTasks#" href="index.cfm?fuseaction=app.tasks">Tasks</a></li>
						<li><a class="#TopNavSchedule#" href="index.cfm?fuseaction=app.schedule">Schedule</a></li>
					</ul>
				</div>
			</div>
			<!--- MAIN --->
			<div id="main">
				<div id="mainnavigation">
					<ul class="#SubNavCollections#">
						<li><a class="#SubNavDashboard#" href="index.cfm?fuseaction=app.dashboard">Dashboard</a></li>
						<li><a class="#SubNavAdd#" href="index.cfm?fuseaction=app.new">Add</a></li>
						<li><a class="#SubNavIndex#" href="index.cfm?fuseaction=app.index">Index</a></li>
						<li><a class="#SubNavUpdate#" href="index.cfm?fuseaction=app.update">Update</a></li>
						<li><a class="#SubNavPurge#" href="index.cfm?fuseaction=app.purge">Purge</a></li>
						<li><a class="#SubNavDelete#" href="index.cfm?fuseaction=app.delete">Delete</a></li>
						<li><a class="#SubNavSearch#" href="index.cfm?fuseaction=app.search">Search</a></li>
					</ul>
				
					<ul class="#SubNavTasks#">
						<li><a class="#SubNavDashboard#" href="index.cfm?fuseaction=app.taskdashboard">Dashboard</a></li>
						<li><a class="#SubNavAdd#" href="index.cfm?fuseaction=app.task">New</a></li>
						<li><a class="#SubNavUpdate#" href="index.cfm?fuseaction=app.taskUpdate">Update</a></li>
						<li><a class="#SubNavDelete#" href="index.cfm?fuseaction=app.taskDelete">Delete</a></li>
					</ul>
				
				</div>
				#body#
			</div>
			<!--- FOOTER --->
			<div id="footer">
				<p class="subscript">
					(c) Copyright #year(now())# Automated Graphics Systems. All Rights Reserved. 
				</p>
			</div>
			
			
			
		</div>
		
		
		
	</body>
	</html>

	</cfoutput>

