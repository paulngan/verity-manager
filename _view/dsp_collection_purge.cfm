<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavCollections = "on">
<cfset SubNavCollections = "on">
<cfset SubNavPurge = "on">
	
<cfparam name="SelectedCollection" type="string" default="">

<cfquery name = "qry_collection_list" datasource = "#dsn#">
    select *
      from tblCollections
     where strServer = '#strServer#'
  order by strCollectionName

</cfquery>

<cfif IsDefined('attributes.collection_ID')>
	<cfquery name = "qry_selected_collection" datasource = "#dsn#">
	    select *
	      from tblCollections
		 where collection_ID = '#attributes.collection_ID#'
	</cfquery>
	<cfset SelectedCollection = qry_selected_collection.collection_ID>
</cfif>


<cfoutput>

	<form name = "purgeCollection" action = "index.cfm" method = "post" >

		<input 	name = "fuseaction" 
				type = "hidden"
				value = "app.purge"
				class="hidden"> 

		<input 	name = "takeaction" 
				type = "hidden"
				value = "true"
				class="hidden">
				
		<cfif attributes.takeaction eq true><sub class="check">#mark_check# Successfully Purged</sub></cfif>
		<label for="strCollectionName"/>Collection</label>
		<select class="valid" name="collection_ID">
			<option value="none"></option>	
			<cfloop query = "qry_collection_list">
				<cfif collection_ID eq SelectedCollection>
					<option selected="selected" value="#collection_ID#">#strCollectionName#</option>
				<cfelse>
					<option value="#collection_ID#">#strCollectionName#</option>
				</cfif>
			</cfloop>
		</select>

		<input 	name = "submit" 
				type = "submit"
				value = "Purge Collection"
				class="submit"> 


	</form>

</cfoutput>