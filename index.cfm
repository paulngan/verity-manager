<cfapplication name="#right(REReplace(expandPath('.'),'[^A-Za-z]','','all'),64)#" />
<cfset FUSEBOX_APPLICATION_PATH = "fusebox">
<cfinclude template="#fusebox_application_path#/fusebox5/fusebox5.cfm" />
