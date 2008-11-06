<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavTasks = "on">
<cfset SubNavTasks = "on">
<cfset SubNavDashboard = "on">
	
	<cfparam name="intcollectionstate" type="numeric" default="2">
	<cfparam name="DDATECOLLECTIONLASTINDEXED" type="numeric" default="0">
	<cfparam name="DDATELASTINDEXSTARTED" type="numeric" default="1">
	<cfparam name="DDATELASTINDEXFINISHED" type="numeric" default="0">
	
	<cfquery name = "qry_task_list" datasource = "#dsn#">
	    select *
	      from tblSchedules
		 where strServer = '#strServer#'
	  order by strTask
	</cfquery>
	
	<cfoutput>

		<div id="dashboard">
			<div id="vertical_container" >
				<strong>Scheduled Tasks: #qry_task_list.recordcount#</strong><br /><br />

				<cfloop query = "qry_task_list">
					<h1 class="accordion_toggle">
						<cfif dtEndDate neq ''> 
							<cfif dateformat(dtEndDate) lte dateformat(now())>
								<font style ="color: ##5c5c5c">#mark_x#</font>
							<cfelse>
								<font style ="color: ##00aa00">#mark_check#</font>
							</cfif>
						<cfelse>
							<cfif dateformat(dtEndDate) gte dateformat(now())>
								<font style ="color: ##5c5c5c">#mark_x#</font>
							<cfelse>
								<font style ="color: ##00aa00">#mark_check#</font>
							</cfif>	
						</cfif>
						
						<!--- SET ICON TO LEFT OF TASK NAME --->
							&nbsp;&nbsp;#strTask#
					</h1>

					<div class="accordion_content">
						<br />
						<table border="0" cellspacing="0" cellpadding="3">
							<tr>
								<td>
									<strong>Collection</strong>
								</td>
								<td>
									<strong>Interval</strong>
								</td>
								<td align="left">
									<strong>Start</strong>
								</td>
								<td align="left">
									<strong>End</strong>
								</td>
							</tr>
							
							<!--- BEGIN DYNAMIC ROW --->
							<tr>
								
								<!--- COLLECTION --->
								<td>
									<cfquery name = "qry_get_collection_name" datasource = "#dsn#">
									    select strCollectionName
									      from tblCollections
									     where collection_id = '#collection_ID#'
									</cfquery>
									#qry_get_collection_name.strCollectionName#
								</td>
								
								<!--- INTERVAL --->
								<td align="left">
									<cfset listInterval = 'once,daily,weekly,monthly'>
									<cfif listfindnocase(listInterval, strInterval)>
										#strInterval#
									<cfelse>
										Custom
									</cfif>
								</td>
								
								<!--- START TIME --->
								<td>
									#dateformat(dtStartDate, 'mm/dd/yy')# #timeformat(dtStartTimeDWM, 'h:mm tt')#
								</td>
								
								<!--- END TIME --->
								<td align="left">
									<cfif dtEndDate neq ''>
										#dateformat(dtEndDate, 'mm/dd/yy')# <cfif dtEndTimeCustom neq ''>#timeformat(dtEndTimeCustom, 'h:mm tt')#</cfif>
									<cfelse>
										N/A
									</cfif>
								</td>
								
								
								
							</tr>
						</table>

						<br />
						<br />

						<div class="dashboardactionstasks">
							<a href="index.cfm?fuseaction=app.taskupdate&tasktoupdate=#strTask#">Update</a>
							<a href="index.cfm?fuseaction=app.taskdelete&strTask=#strTask#&takeaction=true">Delete</a>
						</div>

						<br /><br />

			            <div id="horizontal_container" > </div>

			   		</div>
				</cfloop>

			</div><br />
			<div style="font-size: 80%; text-align: left; position: relative; left: 25px"><font style ="color: ##00aa00">#mark_check#</font> - Task status is good<br />
			<font style="color: ##aa0000">#mark_x#</font> - Task status is bad<br />
			<font style ="color: ##5c5c5c">#mark_x#</font> - Task has expired</div>
		</div>
	</cfoutput>