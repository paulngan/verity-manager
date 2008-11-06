<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavTasks = "on">
<cfset SubNavTasks = "on">
<cfset SubNavAdd = "on">
	
<cfparam name="cssTask" default="">
<cfparam name="cssInterval" default="">
<cfparam name="cssStartTime" default="">
<cfparam name="cssStartDate" default="">
<cfparam name="cssCollection" default="">
<cfparam name="cssintIntervalOther" default="">
<cfparam name="attributes.intIntervalOther" default="">
<cfparam name="attributes.dtEndDate" default="">
<cfparam name="attributes.dtEndTimeCustom" default="">
<cfparam name="attributes.strInterval" default="">
<cfparam name="attributes.dtStartTimeDWM" default="">
<cfparam name="attributes.dtStartDate" default="">
<cfparam name="attributes.collection_ID" default="">
<cfparam name="attributes.strTask" default="">
<cfparam name="check" type="string" default="">

<cfif attributes.takeaction eq 'true'>
	<cfset check = 'check'>
</cfif>



<cfoutput>	

	<form name = "schedule" action = "index.cfm" method = "post" >
	
		<input 	name = "fuseaction" 
				type = "hidden"
				value = "app.task"
				class="hidden"> 
			
		<input 	name = "takeaction" 
				type = "hidden"
				value = "true"
				class = "hidden">
			
		<sub class="#cssCollection#">*Please select a collection</sub>
		<label for="strCollectionName"/>Collection</label>	
		<select class="#cssCollection#" name="collection_ID">
			<option value=""></option>
				<cfloop query = "qry_collection_list">
					<cfif collection_ID eq attributes.collection_ID>
						<option selected="selected" value="#collection_ID#">#strCollectionName#</option>
					<cfelse>
						<option value="#collection_ID#">#strCollectionName#</option>
					</cfif>
				</cfloop>
		</select>
		
		<sub class="#cssTask#">*Invalid Task Name or Name is already taken</sub>
		<sub class="#check#">#mark_check# Successfully Added</sub>
		<label for="strTask">Task Name (e.g. AGS_taskname)</label>
		<input 	name = "strTask" 
				type = "text"
				value = "#attributes.strTask#"
				class="#cssTask#">

		<sub class="#cssInterval#">*Define the Interval</sub>
		<sub class="#check#">#mark_check# Successfully Added</sub>
		<label for="strInterval"/>Interval</label>
		<select name="strInterval" class="#cssInterval#">
			<cfif attributes.strInterval neq ''>
				<option selected="selected">#attributes.strInterval#</option>
			</cfif>
			<option value=""></option>
			<Option>Once</Option>
			<option>Daily</option>
			<option>Weekly</option>
			<option>Monthly</option>
			<option>Custom</option>
		</select>
		
		<sub class="#cssStartTime#">*Define the Start Time</sub>
		<sub class="#check#">#mark_check# Successfully Added</sub>
		<label for="dtStartTimeDWM"/>Start Time* (hh:mm) military</label>		
		<input 	name = "dtStartTimeDWM" 
				type = "text"
				value = "#attributes.dtStartTimeDWM#"
				class="#cssStartTime#">

		<sub class="#cssStartDate#">*Define the Start Date</sub>
		<sub class="#check#">#mark_check# Successfully Added</sub>
		<label for="dtStartDate"/>Start Date* (mm/dd/yy)</label>
		<input 	name = "dtStartDate"
				value="#attributes.dtStartDate#"
				class="#cssStartDate#">
			
		<sub class="#check#">#mark_check# Successfully Added</sub>
		<label for="dtEndTimeCustom"/>End Time (hh:mm) military</label>
		<input 	name = "dtEndTimeCustom" 
				type = "text"
				value="#attributes.dtEndTimeCustom#">
		
		<sub class="#check#">#mark_check# Successfully Added</sub>
		<label for="dtEndDate"/>End Date (mm/dd/yy)</label>
		<input 	name = "dtEndDate" 
				type = "datefield"
				value = "#attributes.dtEndDate#">
		
		<sub class="#cssintIntervalOther#">*Define Interval</sub>
		<sub class="#check#">#mark_check# Successfully Added</sub>
		<label for="intIntervalOther"/>Interval in Seconds (1800 = 30 min) *required for custom intervals</label>
		<input 	name = "intIntervalOther" 
				type = "text"
				value = "#attributes.intIntervalOther#"
				class="#cssintIntervalOther#">
	
		<cfif attributes.takeaction neq 'true'>
			<input 	name = "submit" 
					type = "submit"
					value = "Schedule Task"
					class = "submit">
		</cfif>
		
		
		
	
	</form>

</cfoutput>