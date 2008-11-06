<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavTasks = "on">
<cfset SubNavTasks = "on">
<cfset SubNavUpdate = "on">

<!--- ################################################### --->

	<!--- QUERY DATABASE TO FILL FORM FIELDS --->
	<cfif IsDefined('attributes.TaskToUpdate')>
		
		<cfquery name = "Task" datasource = "#dsn#">
		    select *
		      from tblSchedules
		     where strTask = '#attributes.TaskToUpdate#' AND strServer = '#strServer#'
		</cfquery>
		
		<cfif task.intIntervalOther eq 0>
			<cfset task.intIntervalOther = "">
		</cfif>
		
		<cfquery name = "Collection" datasource = "#dsn#">
		    select *
		      from tblCollections
		     where collection_ID = '#task.collection_ID#'
		</cfquery>
		
	</cfif>
	
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

<!--- ################################################### --->	
	
<cfparam name="attributes.strCollectionName" default="">
<cfparam name="attributes.STRINTERVAL" default="">
<cfparam name="attributes.DTSTARTTIMEDWM" default="">
<cfparam name="attributes.DTSTARTDATE" default="">
<cfparam name="attributes.DTENDTIMECUSTOM" default="">
<cfparam name="attributes.DTENDDATE" default="">
<cfparam name="attributes.INTINTERVALOTHER" default="">

<cfparam name="collection.strCollectionName" default="#attributes.strCollectionName#">
<cfparam name="Task.STRINTERVAL" default="#attributes.STRINTERVAL#">
<cfparam name="Task.DTSTARTTIMEDWM" default="#attributes.DTSTARTTIMEDWM#">
<cfparam name="Task.DTSTARTDATE" default="#attributes.DTSTARTDATE#">
<cfparam name="Task.DTENDTIMECUSTOM" default="#attributes.DTENDTIMECUSTOM#">
<cfparam name="Task.DTENDDATE" default="#attributes.DTENDDATE#">
<cfparam name="Task.INTINTERVALOTHER" default="#attributes.INTINTERVALOTHER#">

<cfparam name="check" type="string" default="">
<cfparam name="attributes.TaskToUpdate" default="">


<cfif attributes.takeaction eq 'true'>
	<cfset check = 'check'>
</cfif>



<cfoutput>	
	
	<form name = "ChooseTask" action = "index.cfm" method = "post">

		<input 	name = "fuseaction" 
				type = "hidden"
				value = "app.taskupdate"
				class = "hidden"> 
				<!--- Task Update --->

		<label for="TaskToUpdate"/>Task</label>	
		<select name="TaskToUpdate">
			
			<cfif IsDefined('attributes.TaskToUpdate')>
				<option value="#attributes.TaskToUpdate#">#attributes.TaskToUpdate#</option>
			<cfelse>
				<option value="none"></option>
			</cfif>
			
			<cfloop query = "qry_task_list">
				<option value="#strTask#">#strTask#</option>
			</cfloop>
			
		</select>
		

	
		<input 	type="submit" 
				name="submit" 
				value="Refresh Page"
				class="submit">

	</form>

	<br />

	<form name = "schedule" action = "index.cfm" method = "post" >
	
		<input 	name = "fuseaction" 
				type = "hidden"
				value = "app.taskupdate"
				class="hidden"> 
			
		<input 	name = "takeaction" 
				type = "hidden"
				value = "true"
				class = "hidden">
				
		<input 	name = "strTask" 
				type = "hidden"
				value = "#attributes.TaskToUpdate#"
				class = "hidden">
				
			
		<label for="strCollectionName"/>Collection</label>	
		<input 	name = "strCollectionName"
				type = "text"
				readonly = "readonly"
				value = "#collection.strCollectionName#">
		</select>
		
		<sub class="#check#">#mark_check# Successfully Updated</sub>
		<label for="strInterval"/>Interval</label>
		<select name="strInterval">
			<option>#task.strInterval#</option>
			<Option>Once</Option>
			<option>Daily</option>
			<option>Weekly</option>
			<option>Monthly</option>
			<option>Custom</option>
		</select>

		<sub class="#check#">#mark_check# Successfully Updated</sub>
		<label for="dtStartTimeDWM"/>Start Time* (hh:mm) military</label>		
		<input 	name = "dtStartTimeDWM" 
				type = "text"
				value = "#TimeFormat(Task.dtStartTimeDWM, 'hh:mm tt')#">

		<sub class="#check#">#mark_check# Successfully Updated</sub>		
		<label for="dtStartDate"/>Start Date* (mm/dd/yy)</label>
		<input 	name = "dtStartDate" 
				type = "text"
				value = "#task.dtStartDate#">
			
		<sub class="#check#">#mark_check# Successfully Updated</sub>
		<label for="dtEndTimeCustom"/>End Time (hh:mm) military</label>
		<input 	name = "dtEndTimeCustom" 
				type = "text"
				value = "#task.dtEndTimeCustom#">
		
		<sub class="#check#">#mark_check# Successfully Updated</sub>
		<label for="dtEndDate"/>End Date (mm/dd/yy)</label>
		<input 	name = "dtEndDate" 
				type = "datefield"
				class = "#task.dtEndDate#">
		
		<sub class="#check#">#mark_check# Successfully Updated</sub>
		<label for="intIntervalOther"/>Interval in Seconds (1800 = 30 min) *required for custom intervals</label>
		<input 	name = "intIntervalOther" 
				type = "text"
				value = "#task.intIntervalOther#">
	
	<cfif attributes.takeaction neq 'true'>
		<input 	name = "submit" 
				type = "submit"
				value = "Update Task"
				class = "submit">	
	</cfif>
	
	
		
	
	</form>
	

</cfoutput>