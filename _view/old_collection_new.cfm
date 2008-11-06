



<cfoutput>
	
	<div class="form">
		
		
		<!--- ########################################################################### --->
		
		<!--- DISPLAY CONFIRMATION OF ACTION TAKEN TO USER --->
		<cfif isdefined('attributes.takeaction') AND (attributes.takeaction neq false)>
			
			<cfparam name="attributes.strCollection" type="string" default="testCollection">

			<h3>Collection Successfully Added</h3>
			<br />
				<table border="1" cellpadding="7" cellspacing="0" align="center" style="background-color: ##ffffff; color: ##000000">
					<tr>
						<td colspan="2" style="background-color: ##999999; color: ##000000">
							Collection
						</td>
					</tr>

					<tr>
						<td colspan="2" style="background-color: ##ffffff; color: ##000000">
							#attributes.strCollectionName#
						</td>
					</tr>
					<tr>
						<td style="background-color: ##999999;">
							Directory Path
						</td>
						<td style="background-color: ##999999;">
							Added
						</td>
					</tr>
						<cfloop query="qry_directories">
							<!--- Display that this directory has been added to collection --->
							<tr>
								<td style="text-align: left">
									#directory#\#name#
								</td>
								<td style="color: ##cc0000">
									#mark_check#;
								</td>
							</tr>
						</cfloop>
						<tr>
							<td colspan="2" style="background-color: ##999999;">Indexed At:</td>
						</tr>
					<tr>
						<td colspan="2" >
							#DateFormat(Now(), "mm/dd/yyyy")#&nbsp;#TimeFormat(Now(), "hh:mm:ss")#
						</td>
					</tr>
					<tr>
						<td colspan="2" style="background-color: ##999999;">Return Path:</td>
					</tr>
					<tr>
						<td colspan="2" >#strCollectionRetUrl#</td>
					</tr>

				</table>
				<br />
				
				<p class="sublinks">
						
						<a href="index.cfm?fuseaction=app.new">Add another collection</a><br />
						<a href="index.cfm?fuseaction=app.index">Index a collection</a><br />
						<a href="index.cfm?fuseaction=app.update">Update a collection</a><br />
						<a href="index.cfm?fuseaction=app.purge">Purge a collection</a><br />
						<a href="index.cfm?fuseaction=app.delete">Delete a collection</a>

				</p><br />
			
		<!--- ########################################################################### --->
			
		
		<cfelse>
			
			<h3>New Collection</h3><br /><br />
			
			<cfform name = "newcollection" action = "index.cfm" method = "post" format = "flash" height="300" width="455">
				
				
				<!--- SETS THE CFINPUT REQUIRED ATTRIBUTE TO YES OR NO --->

				<cfset required = "yes">			
				
				<!--- SET FUSEACTIONS AND SET TAKEACTION VARIABLE --->
					
				<cfinput type="hidden" 
						 name="fuseaction" 
						 value="app.new">
				
				<cfinput type="hidden"
						 name="takeaction"
						 value="true">
				

				<cfinput name = "strCollectionName" 
						 type = "text"
						 value = ""
						 size = "20"
						 label = "Name: " 
						 required = "#required#"
						 message = "Missing Name">
				
				<cfinput name = "strCollectionPath" 
						 type = "text"
						 value = "#defaultCollectionPath#"
						 size = "20"
						 label = "Path: " 
						 required = "#required#"
						 message = "Missing Path"> 
						
				<cfinput name = "strCollectionRetUrl" 
						 type = "text"
						 value = ""
						 size = "20"
						 label = "Return URL: " 
						 required = "#required#"
						 message = "Missing Return URL">
						
				<cfinput name = "strCollectionFileExt" 
						 type = "text"
						 value = ""
						 size = "20"
						 label = "File Types to Index (comma delimited): " 
						 required = "#required#"
						 message = "Missing File Types"> 

				<cfinput name = "strExcludedDirectories" 
						 type = "text"
						 value = ""
						 size = "20"
						 label = "Excluded Directories (comma delimited): " 
						 required = "no"
						 message = "Excluded Directories"> 
			
			
			<cfformgroup type="horizontal">	
			
					<cfinput type="submit" 
							 name="submit" 
							 value="Add Collection">
				
			</cfformgroup>	
			
				
			</cfform>
			
		</cfif>
	
	</div>
	
</cfoutput>