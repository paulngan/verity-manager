<!--- SET TAB CSS ATTRIBUTES --->
<cfset TopNavCollections = "on">
<cfset SubNavCollections = "on">
<cfset SubNavIndex = "on">
	
<cfparam name="SelectedCollection" type="string" default="">

<cfoutput>
	
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
		
					
		<form name = "index" action = "index.cfm" method = "post">

		<input 	name = "fuseaction" 
				type = "hidden"
				value = "app.index"
				class="hidden"> 

		<input 	name = "takeaction" 
				type = "hidden"
				value = "true"
				class="hidden">
		
		<label for="strCollectionName"/>Collection</label>	
		<select class="valid" name="collection_id">
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
				value = "Index Collection"
				class = "submit"> 

	</form>
	
	<br />
	
	<cfif attributes.takeaction eq true>
		
		<cfquery name = "qry_collection_list" datasource = "#dsn#">
		    select *
		      from tblCollections
		     where collection_id = '#attributes.collection_id#'
		</cfquery>
		
		<cfquery name = "qry_directory_list" datasource = "#dsn#">
		    select *
		      from tblDirectories
		     where collection_id = '#attributes.collection_id#'
		</cfquery>
		
		
		<cfparam name="check" type="string" default="off">
		<cfif attributes.takeaction eq true>
			<cfset check = 'check'>
		</cfif>
		
		
		<form action="" method="post">
			
			<sub class="#check#">#mark_check# Successfully Indexed</sub>
			<label for="strCollectionName">Collection</label>
			<input type="text" name="strCollectionName" value="#qry_collection_list.strCollectionName#">
			
			<sub class="#check#">#mark_check# Successfully Indexed</sub>
			<label for="strCollectionName">Directory Path</label>
			<cfloop query="qry_directory_list">
				<input type="text" name="strDirectoryPath" value="#strDirectoryPath#">
			</cfloop>
			
			<sub class="#check#">#mark_check# Successfully Indexed</sub>
			<label for="strReturnURL">Return URL</label>
			<input type="text" name="strReturnURL" value="#qry_collection_list.strCollectionRetUrl#">
			
			<sub class="#check#">#mark_check# Successfully Indexed</sub>
			<label for="dtDateIndexed">Date/Time Indexed</label>
			<input type="text" name="dtDateIndexed" value="#DateFormat(Now(), "mm/dd/yyyy")#&nbsp;#TimeFormat(Now(), "hh:mm:ss")#">
			
			
				
		</form>
		
	</cfif>			

	

</cfoutput>