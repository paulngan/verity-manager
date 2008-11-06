<!---
<cfparam name="attributes.strInterval" type="string" default="">
<cfif attributes.strInterval eq 'Custom'>
	<cfset form.strInterval = attributes.intIntervalOther>
</cfif>

<cfset form.dtStartTimeDWM = #TimeFormat(attributes.dtStartTimeDWM, 'hh:mm tt')#>
<cfset form.dtEndTimeCustom = #TimeFormat(attributes.dtEndTImeCustom, 'hh:mm tt')#>
<cfset form.strTask = "Verity_#form.strTask#">

--->
<cfdump var = "#form#">
