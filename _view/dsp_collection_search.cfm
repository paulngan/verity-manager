<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavCollections = "on">
<cfset SubNavCollections = "on">
<cfset SubNavSearch = "on">
	
<cfparam name="SelectedCollection" type="string" default="">

	<cfif IsDefined('attributes.collection_ID')>
		<cfquery name = "qry_selected_collection" datasource = "#dsn#">
		    select *
		      from tblCollections
			 where collection_ID = '#attributes.collection_ID#'
		</cfquery>
		<cfset SelectedCollection = qry_selected_collection.collection_ID>
	</cfif>


<cfoutput>
	

	<form action="index.cfm" method="get">
		
		<input 	type="hidden" 
				name="fuseaction" 
				value="app.search" 
				id="fuseaction"
				class="hidden">
				
		<input 	type="hidden" 
				name="takeaction" 
			   	value="true" 
			   	id="takeaction"
				class="hidden">	
				
		<label for="CollectionToSearch"/>Collection</label>			
		<select	name = "CollectionToSearch">
			<option value="none"></option>
			<cfloop query = "qry_collection_list">
				<cfif collection_ID eq SelectedCollection>
					<option selected="selected" value="#collection_ID#">#strCollectionName#</option>
				<cfelse>
					<option value="#collection_ID#">#strCollectionName#</option>
				</cfif>
			</cfloop>	
					
		</select>
		
		<label for="SearchCriteria"/>Search Criteria</label>
		<input 	type="text"
				name="SearchCriteria">

		<input 	name = "submit" 
				type = "submit"
				value = "Search"
				class="submit"> 
		
		
		<cfif attributes.takeaction eq true>
				
			<br /><br />

				<cfoutput>
					<strong>
						<cfif qry_search_results.recordcount eq 1>
							#qry_search_results.recordcount# record matched your search.
						<cfelse>
							#qry_search_results.recordcount# records matched your search. 
						</cfif>
					</strong>
				</cfoutput>
			
			<br />				
							
			<cfloop query = "qry_search_results">
				<dl class="##"><dt><a href="#url#"><cfif len(title) lt 1>Document<cfelse>#title#</cfif></a></dt>
					<dd>#summary#</dd>
					<dd><a href="#url#">View Document</a></dd></dl>
			</cfloop>

		</cfif>
	
		</form>
</cfoutput>