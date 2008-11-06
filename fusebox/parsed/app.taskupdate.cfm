<cfsetting enablecfoutputonly="true" />
<cfprocessingdirective pageencoding="utf-8" />
<!--- circuit: app --->
<!--- fuseaction: taskupdate --->
<cftry>
<cfset myFusebox.thisPhase = "appinit">
<cfset myFusebox.thisCircuit = "app">
<cfset myFusebox.thisFuseaction = "taskupdate">
<cfif myFusebox.applicationStart>
	<cfif not myFusebox.getApplication().applicationStarted>
		<cflock name="#application.ApplicationName#_fusebox_#FUSEBOX_APPLICATION_KEY#_appinit" type="exclusive" timeout="30">
			<cfif not myFusebox.getApplication().applicationStarted>
<!--- fuseaction action="m.initialize" --->
<cfset myFusebox.thisCircuit = "m">
<cfset myFusebox.thisFuseaction = "initialize">
<cfset myFusebox.getApplication().getApplicationData().startTime = "#now()#" />
<cfset myFusebox.thisCircuit = "app">
<cfset myFusebox.thisFuseaction = "taskupdate">
				<cfset myFusebox.getApplication().applicationStarted = true />
			</cfif>
		</cflock>
	</cfif>
</cfif>
<!--- do action="m.task_update" --->
<cfset myFusebox.thisPhase = "requestedFuseaction">
<cfset myFusebox.thisCircuit = "m">
<cfset myFusebox.thisFuseaction = "task_update">
<cftry>
<cfoutput><cfinclude template="../../_model/action/act_task_update.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 26 and right(cfcatch.MissingFileName,26) is "action/act_task_update.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse action/act_task_update.cfm in circuit m which does not exist (from fuseaction m.task_update).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<!--- do action="v.task_update" --->
<cfset myFusebox.thisCircuit = "v">
<cftry>
<cfsavecontent variable="body"><cfoutput><cfinclude template="../../_view/dsp_task_update.cfm"></cfoutput></cfsavecontent>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 19 and right(cfcatch.MissingFileName,19) is "dsp_task_update.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse dsp_task_update.cfm in circuit v which does not exist (from fuseaction v.task_update).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cftry>
<cfoutput><cfinclude template="../../_view/lay_template.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 16 and right(cfcatch.MissingFileName,16) is "lay_template.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse lay_template.cfm in circuit v which does not exist (from fuseaction v.$postfuseaction).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cfcatch><cfrethrow></cfcatch>
</cftry>
<cfsetting enablecfoutputonly="false" />

