<cfoutput>
	
	<cfif attributes.takeaction eq true>
	
		<cfset error = false>
			
			<cfif attributes.collection_ID eq ''>
				<cfset error = 'true'>
				<cfset cssCollection = 'invalid'>
			<cfelse>

				<!--- CHECK DATABASE TO SEE IF COLLECTION NAME IS TAKEN --->
				<cfquery name = "qry_IsTaskNameTaken" datasource = "#dsn#">
				    select strTask
				      from tblSchedules
				     where strTask = '#strTask#' AND strServer = '#strServer#'
				</cfquery>

				<cfset RecordCount = qry_IsTaskNameTaken.RecordCount>

				<cfif RecordCount >
					<cfset error = true>
					<cfset cssTask = 'invalid'>
					<cfset TaskNameTaken = 'true'>
				</cfif>
			
			</cfif>
			
			

		<!--- CHECK TASK NAME --->
		<cfif len(attributes.strTask) lt 2>
			<cfset error = true>
			<cfset cssTask = 'invalid'>
		</cfif>


		<!--- CHECK INTERVAL --->
		<cfif attributes.strInterval eq 'none' OR attributes.strInterval eq ''>
			<cfset error = true>
			<cfset cssInterval = 'invalid'>
		</cfif>


		<!--- CHECK START DATE --->
		<cfif len(attributes.dtStartDate) lt 6>
			<cfset error = true>
			<cfset cssStartDate = 'invalid' >
		</cfif>
		
		<!--- CHECK START TIME --->
		<cfif len(attributes.dtStartTimeDWM) lt 4>
			<cfset error = true>
			<cfset cssStartTime = 'invalid' >
		</cfif>
		
		<!--- CHECK INPUT FOR COLLECTION RETURN URL --->
		<cfif attributes.strInterval eq 'Custom' and attributes.intIntervalOther eq ''>
			<cfset error = true>
			<cfset cssintIntervalOther = 'invalid' >
		</cfif>


		<!--- IF ERROR EXISTS DISABLE TAKEACTION AND RETURN TO FORM --->
		<cfif error eq 'true' >
			<cfset attributes.takeaction = 'false' >
		</cfif>
	
	</cfif>
	
</cfoutput>