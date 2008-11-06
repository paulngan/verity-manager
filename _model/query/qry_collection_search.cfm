<cfif attributes.takeaction eq true>
	
	<cfparam name="attributes.SearchCriteria" type="string" default="">
	<cfparam name="Criteria" type="string" default="">
		
	<cfif attributes.SearchCriteria eq '' OR attributes.SearchCriteria eq ' '>
		<cfset Criteria = ''>
	<cfelse>
		<cfset Criteria = '<WORD>#attributes.SearchCriteria#'>
	</cfif>
		
		
	
	
	<!--- CONVERT THE COLLECTION_ID VARIABLE INTO THE STRCOLLECTIONNAME FOR THE CFSEARCH --->
	<cfquery name = "Collection" datasource = "#dsn#">
	    select strCollectionName
	      from tblCollections
	     where collection_ID = '#attributes.CollectionToSearch#'
	</cfquery>
	
	<cfsearch 	collection="#Collection.strCollectionName#" 
				name="qry_search_results" 
				type="explicit" 
				language="English"
				criteria = "#Criteria#">
	
</cfif>


				