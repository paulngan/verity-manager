<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavCollections = "on">
<cfset SubNavCollections = "on">
<cfset SubNavDelete = "on">


<cfoutput>

	
	<form name = "DeleteCollection" action = "index.cfm" method = "post">

		<input name = "fuseaction" 
				 type = "hidden"
				 value = "app.delete"
				 class="hidden"> 

		<input name = "takeaction" 
				 type = "hidden"
				 value = "true"
				 class="hidden">
			
		<cfif attributes.takeaction eq true><sub class="check">#mark_check# Successfully Deleted</sub></cfif>
		<label for="strCollectionName"/>Collection</label>
		<select class="valid" name="strCollectionName">
			<cfif IsDefined("attributes.strCollection")>
				<option>#attributes.strCollection#</option>
			<cfelse>
				<option value="none"></option>	
			</cfif>
			
			<cfloop query = "qry_collection_list">
				<option value="#collection_ID#">#strCollectionName#</option>
			</cfloop>
		</select>

		<input 	name = "submit" 
				type = "submit"
				value = "Delete Collection"
				class = "submit"> 

	</form>


</cfoutput>