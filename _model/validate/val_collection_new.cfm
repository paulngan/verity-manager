<cfoutput>
	
	<cfif attributes.takeaction eq true>
	
		<cfset error = false>

		<!--- CHECK DATABASE TO SEE IF COLLECTION NAME IS TAKEN --->
		<cfquery name = "qry_IsCollectionNameTaken" datasource = "#dsn#">
		    select strCollectionName
		      from tblCollections
		     where strCollectionName = '#attributes.strCollectionName#' AND strServer = '#strServer#'
		</cfquery>

		<cfset RecordCount = qry_IsCollectionNameTaken.RecordCount>

		<cfif RecordCount >
			<cfset error = true>
			<cfset classStrCollectionName = 'invalid'>
		</cfif>
		
		
		<!--- CHECK INPUT FOR COLLECTION NAME --->
		<cfif len(attributes.strCollectionName) lt 1>
			<cfset error = true>
			<cfset classStrCollectionName = 'invalid'>
		</cfif>


		<!--- CHECK INPUT FOR COLLECTION PATH --->
		<cfif attributes.STRCOLLECTIONPATH eq defaultCollectionPath>
			<cfset error = true>
			<cfset classStrCollectionPath = 'invalid'>
		</cfif>


		<!--- CHECK INPUT FOR COLLECTION RETURN URL --->
		<cfif len(attributes.STRCOLLECTIONRETURL) lt 1>
			<cfset error = true>
			<cfset classStrCollectionRetURL = 'invalid' >
		</cfif>


		<!--- IF ERROR EXISTS DISABLE TAKEACTION AND RETURN TO FORM --->
		<cfif error >
			<cfset attributes.takeaction = false >
		</cfif>
	
	</cfif>
	
</cfoutput>





