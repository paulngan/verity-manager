<cfoutput>
	<cfif attributes.takeaction eq true>
		<cfif attributes.collection_ID eq 'none'>
			<cfset attributes.takeaction = false>
			<cfset StructDelete(attributes, 'collection_ID')>
		</cfif>
	</cfif>
</cfoutput>