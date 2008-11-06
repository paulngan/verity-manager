<!--- SET CLASS ATulIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavCollections = "on">
<cfset SubNavCollections = "on">
<cfset SubNavDashboard= "on">
	
<cfparam name="DDATECOLLECTIONLASTINDEXED" type="numeric" default="0">
<cfparam name="DDATELASTINDEXSTARTED" type="numeric" default="1">
<cfparam name="DDATELASTINDEXFINISHED" type="numeric" default="0">
	

	
<cfoutput>
	
	<cfquery name = "qry_collection_list" datasource = "#dsn#">
	    select *
	      from tblCollections
	     where strServer = '#strServer#'
	  order by strCollectionName

	</cfquery>

	
	<div id="dashboard">
		<div id="vertical_container" >
			<strong>Registered Collections: #qry_collection_list.recordcount#</strong><br /><br />
			
			<cfloop query = "qry_collection_list">
				<h1 class="accordion_toggle"> 
								
					<cfswitch expression="#intCollectionState#">
						<cfcase value="1">
							<cfif DDATELASTINDEXSTARTED lt DDATELASTINDEXFINISHED>
								<font style ="color: ##00aa00">#mark_check#</font>
							<cfelse>
								<font style="color: ##aa0000">#mark_x#</font>
							</cfif>
						</cfcase>
						<cfcase value="2"><font style ="color: ##5d5d5d">&nbsp;&nbsp;</font></cfcase>
						<cfcase value="3"><font style ="color: ##5c5c5c">#mark_check#</font></cfcase>
						<cfcase value="4"><font style ="color: ##5c5c5c">#mark_x#</font></cfcase>
						<cfdefaultcase>&nbsp;&nbsp;</cfdefaultcase>
					</cfswitch>
						
						&nbsp;&nbsp;#strCOLLECTIONNAME#
				</h1>
				
				<div class="accordion_content">
					<br />
					<table border="0" cellspacing="0" cellpadding="3">
						<tr>
							<td>
								<strong><cfif DDATELASTINDEXSTARTED gt DDATELASTINDEXFINISHED AND len(DDATECOLLECTIONLASTINDEXED) gt 1>Last Attempt<cfelseif Len(DDATECOLLECTIONLASTINDEXED) lt 1>Not Yet Indexed<cfelse>Last Indexed</cfif></strong>
							</td>
							<td>
								<strong>Time</strong>
							</td>
							<td align="center">
								<strong>State</strong>
							</td>
							<td align="right">
								<strong>Status</strong>
							</td>
						</tr>
						<tr>
							<td>
								<cfif Len(DDATECOLLECTIONLASTINDEXED) gt 1>
									#DateFormat(DDATECOLLECTIONLASTINDEXED, "MM/DD/YY")# #TimeFormat(DDATECOLLECTIONLASTINDEXED, "h:mm tt")#
								<cfelse>
									<a href="index.cfm?fuseaction=app.index&collection_id=#collection_ID#&takeaction=true">Index Now</a>
								</cfif>
							</td>
							<td>
								<cfif len(ddatelastindexfinished) gte 1 >
									<cfset CollectionDuration = round(Datediff('s',DDATELASTINDEXSTARTED,DDATELASTINDEXFINISHED)/60) >
									<cfif CollectionDuration lte 0>
										&nbsp;&nbsp;&nbsp;0
									<cfelse>
										#CollectionDuration# min
									</cfif>
								<cfelse>	
									&nbsp;N/A
								</cfif>
							</td>
							<td align="center">
								<cfswitch expression="#intCollectionState#">
									<cfcase value="1">Indexed</cfcase>
									<cfcase value="2">New - Index Now</cfcase>
									<cfcase value="3">Updated - Index Now</cfcase>
									<cfcase value="4">Purged</cfcase>
									<cfdefaultcase>N/A</cfdefaultcase>
								</cfswitch>
								
							</td>
							<td align="right">
								<cfif len(DDATELASTINDEXSTARTED) gt 1 >			
									<cfif DDATELASTINDEXSTARTED lt DDATELASTINDEXFINISHED>
										<font style ="color: ##00aa00">#mark_check#&nbsp;&nbsp;</font>
									<cfelse>
										<font style="color: ##aa0000">#mark_x#&nbsp;&nbsp;</font>
									</cfif>
									&nbsp;
								<cfelse>
									&nbsp;N/A&nbsp;&nbsp;
								</cfif>
							</td>
						</tr>
					</table>
					
					<br />
					<br />
					
					<div class="dashboardactions">
						<a href="index.cfm?fuseaction=app.index&collection_id=#collection_ID#&takeaction=true">Index</a>
						<a href="index.cfm?fuseaction=app.update&collection_id=#collection_id#">Update</a>
						<a href="index.cfm?fuseaction=app.purge&collection_id=#collection_ID#&takeaction=true">Purge</a>
						<a href="index.cfm?fuseaction=app.delete&strCollectionName=#strCollectionName#&takeaction=true">Delete</a>
						<a href="index.cfm?fuseaction=app.search&collection_id=#collection_id#">Search</a>
					</div>
					
					<br /><br />
					
		            <div id="horizontal_container" > </div>
		
		   		</div>
			</cfloop>
			
		</div><br />
		<div style="font-size: 80%; text-align: left; position: relative; left: 25px"><font style ="color: ##00aa00">#mark_check#</font> - Indexed & Error Free<br />
		<font style="color: ##aa0000">#mark_x#</font> - Error Indexing<br />
		<font style ="color: ##5c5c5c">#mark_check#</font> - Indexed but Collection has been Updated<br />
		<font style ="color: ##5c5c5c">#mark_x#</font> - Collection has been Purged</div>
	</div>
</cfoutput>