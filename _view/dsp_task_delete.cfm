<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavTasks = "on">
<cfset SubNavTasks = "on">
<cfset SubNavDelete = "on">
	
	
	<cfquery name = "qry_task_list" datasource = "#dsn#">
	    select *
	      from tblSchedules
		 where strServer = '#strServer#'
	  order by strTask
	</cfquery>

	<cfif IsDefined('attributes.strTask')>
		<cfquery name = "qry_selected_task" datasource = "#dsn#">
		    select *
		      from tblSchedules
			 where strTask = '#attributes.strTask#' AND strServer = '#strServer#'
		</cfquery>
		<cfset SelectedTask = qry_selected_task.strTask>
	</cfif>

<cfparam name="SelectedTask" type="string" default="">

<cfoutput>

	<form name = "deletetask" action = "index.cfm" method = "post" format = "flash" width="350" height="300" onLoad="alert('WARNING!\nTHIS PAGE IS FOR DELETING TASKS\nPLEASE BE CAREFUL')">
	
		<input 	name = "fuseaction" 
				type = "hidden"
				value = "app.taskdelete"
				class = "hidden"> 
	
		<input 	name = "takeaction" 
				type = "hidden"
				value = "true"
				class = "hidden">
	
		<!--- DISPLAY DROP DOWN WITH ALL TASKS --->		
		<cfif attributes.takeaction eq 'true'><sub class="check">#mark_check# Successfully Deleted</sub></cfif>
		<label for="strTask"/>Task</label>
		<select class="valid" name="strTask" onChange = "alert('You are about to delete a task');">
			<option value="none"></option>	
			<cfloop query = "qry_task_list">
				<cfif strTask eq SelectedTask>
					<option selected="selected" value="#collection_ID#">#strCollectionName#</option>
				<cfelse>
					<option value="#strTask#">#strTask#</option>
				</cfif>
			</cfloop>
		</select>

			<input 	name = "submit" 
					type = "submit"
					value = "Delete"
					class = "submit"> 

	</form>


</cfoutput>
