<!---
Copyright 2006 TeraTech, Inc. http://teratech.com/

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->
<cfcomponent output="false" hint="I am the Fusebox application object, formerly the application.fusebox data structure.">

	<cfscript>
	// initialize the fusebox (available to be read by developers but not to be written to)
	this.isFullyLoaded = false;
	this.circuits = structNew();
	this.classes = structNew();
	this.lexicons = structNew();
	this.plugins = structNew();
	this.pluginphases = structNew();
	this.nonFatalExceptionPrefix = "INFORMATION (can be ignored): ";

	this.precedenceFormOrURL = "form";
	this.defaultFuseaction = "";
	this.fuseactionVariable = "fuseaction";
	// this is ignored:
	this.parseWithComments = false;
	this.ignoreBadGrammar = true;
	this.allowLexicon = true;
	this.useAssertions = true;
	this.conditionalParse = false;
	
	this.password = "";
	this.mode = "production";
	this.scriptLanguage = "cfmx";
	this.scriptFileDelimiter = "cfm";
	this.maskedFileDelimiters = "htm,cfm,cfml,php,php4,asp,aspx";
	this.characterEncoding = "utf-8";
	// this is ignored:
	this.parseWithIndentation = this.parseWithComments;
	this.strictMode = false;
	this.allowImplicitCircuits = false;
	this.debug = false;
	</cfscript>
	
	<cffunction name="init" returntype="fuseboxApplication" access="public" output="false" 
				hint="I am the constructor.">
		<cfargument name="appKey" type="string" required="true" 
					hint="I am FUSEBOX_APPLICATION_KEY." />
		<cfargument name="appPath" type="string" required="true" 
					hint="I am FUSEBOX_APPLICATION_PATH." />
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />
		<cfargument name="callerPath" type="string" required="true" 
					hint="I am FUSEBOX_CALLER_PATH." />
		
		<!--- ticket 171 created Fusebox 5.1.0 --->
<!--- 		
		<cfset var myVersion = "5.1.0.#REReplace('$LastChangedRevision: 320 $','[^0-9]','','all')#" />
 --->		
		<cfset var myVersion = "5.1.0" />

		<cfset variables.factory = createObject("component","fuseboxFactory").init() />
		<cfset variables.fuseboxLexicon = variables.factory.getBuiltinLexicon() />
		<cfset variables.customAttributes = structNew() />
		
		<cfset variables.fuseboxFileExtension = "" />

		<cfset variables.fuseboxVersion = myVersion />
		
		<cfset variables.appKey = arguments.appKey />
		<cfset this.webrootdirectory = replace(getDirectoryFromPath(getBaseTemplatePath()),"\","/","all") />
		<cfset variables.coreRoot = replace(getDirectoryFromPath(getCurrentTemplatePath()),"\","/","all") />

		<cfset this.approotdirectory = getCanonicalPath(normalizePartialPath(arguments.callerPath) & normalizePartialPath(arguments.appPath)) />

		<!--- this works on all platforms: --->
		<cfset this.osdelimiter = "/" />

		<cfset this.coreToAppRootPath = relativePath(variables.coreRoot,this.approotdirectory) />
		<cfset this.appRootPathToCore = relativePath(this.approotdirectory,variables.coreRoot) />
		<cfset this.coreToWebRootPath = relativePath(variables.coreRoot,this.webrootdirectory) />
		<cfset this.WebRootPathToCore = relativePath(this.webrootdirectory,variables.coreRoot) />
		
		<cfset this.parsePath = "parsed/" />
		<cfset this.parseRootPath = "../" />
		<cfset this.pluginsPath = "plugins/" />
		<cfset this.lexiconPath = "lexicon/" />
		<cfset this.errortemplatesPath = "errortemplates/" />
		
		<!--- new in Fusebox 5.1: --->
		<cfset this.self = "index.cfm" />
		<cfset this.queryStringStart = "?" />
		<cfset this.queryStringSeparator = "&" />
		<cfset this.queryStringEqual = "=" />
		
		<cfset this.circuits = structNew() />
		<cfset reload(arguments.appKey,arguments.appPath,arguments.myFusebox) />

		<cfif this.strictMode>
			<!--- rootdirectory was deprecated in Fusebox 5 so we no longer set it it strict mode: --->
			<cfset structDelete(this,"rootdirectory") />
		<cfelse>
			<!--- for FB4.0 compatibility: --->
			<cfset this.rootdirectory = this.approotdirectory />
		</cfif>
		
		<cfreturn this />

	</cffunction>

	<cffunction name="reload" returntype="void" access="public" output="false" 
				hint="I (re)load the fusebox.xml file into memory and (re)load all of the application components referenced by that.">
		<cfargument name="appKey" type="string" required="true" 
					hint="I am FUSEBOX_APPLICATION_KEY." />
		<cfargument name="appPath" type="string" required="true" 
					hint="I am FUSEBOX_APPLICATION_PATH." />
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />
		
		<cfset var fbFile = "fusebox.xml.cfm" />
		<cfset var fbFileAlt = "fusebox.xml" />
		<cfset var fbXML = "" />
		<cfset var fbCode = "" />
		<cfset var encodings = 0 />
		<cfset var needToLoad = true />
		<cfset var fuseboxFiles = 0 />
		<cfset var myFuseboxFilePath = "" />
		<cfset var jFuseboxFile = "" />
		<cfset var dtLastModified = "" />
		
		<!---
			since we need to check the file, regardless of whether we load it,
			we might as well do the test up front and perform the strict check
			that just one version exists (ticket 135)
		--->
		<cfif fileExists(this.approotdirectory & fbFile)>
			<cfif this.strictMode and fileExists(this.approotdirectory & fbFileAlt)>
				<cfthrow type="fusebox.multipleFuseboxXML" 
						message="Both 'fusebox.xml' and 'fusebox.xml.cfm' exist" 
						detail="'fusebox.xml.cfm' will be used but 'fusebox.xml' also exists in '#this.approotdirectory#." />
			</cfif>
		<cfelse>
			<cfset fbFile = fbFileAlt />
		</cfif>

		<cfif structKeyExists(this,"timestamp")>
			<!--- Java timestamp solution provided by Daniel Schmid --->
			<cfset myFuseboxFilePath = this.approotdirectory & fbFile />
			<cfset jFuseboxFile = createObject("java","java.io.File").init(myFuseboxFilePath) />
			<cfset dtLastModified = createObject("java","java.util.Date").init(jFuseboxFile.lastModified()) />
			<cfset needToLoad = parseDateTime(dtLastModified) gt parseDateTime(this.timestamp) />
		</cfif>

		<cfif needToLoad>
			<cfif this.debug>
				<cfset arguments.myFusebox.trace("Compiler","Loading fusebox.xml file") />
			</cfif>
			<!--- attempt to load fusebox.xml(.cfm): --->
			<cftry>
				
				<cffile action="read" file="#this.approotdirectory##fbFile#"
						variable="fbXML"
						charset="#this.characterEncoding#" />
						
				<cfset variables.fuseboxFileExtension = listLast(fbFile,".") />
				
				<cfcatch type="any">
					<cfthrow type="fusebox.missingFuseboxXML" 
							message="missing fusebox.xml" 
							detail="The file '#fbFile#' could not be found in the directory #this.approotdirectory#."
							extendedinfo="#cfcatch.detail#" />
				</cfcatch>
				
			</cftry>
			
			<cftry>
				
				<cfset fbCode = xmlParse(fbXML) />
				
				<!--- see if we need to re-read based on the encoding being different to our default --->
				<cfset encodings = xmlSearch(fbCode,"/fusebox/parameters/parameter[@name='characterEncoding']") />
				<cfif arrayLen(encodings) eq 1 and structKeyExists(encodings[1].xmlAttributes,"value")>
					<cfif encodings[1].xmlAttributes.value is not this.characterEncoding>
						<cfset this.characterEncoding = encodings[1].xmlAttributes.value />
						<!--- now re-read the file in case anything is changed in that new encoding --->
						<cffile action="read" file="#this.approotdirectory##fbFile#"
								variable="fbXML"
								charset="#this.characterEncoding#" />
						<cfset fbCode = xmlParse(fbXML) />
					</cfif>
				</cfif>
				
				<cfcatch type="any">
					<cfthrow type="fusebox.fuseboxXMLError" 
							message="Error reading fusebox.xml" 
							detail="A problem was encountered while reading the #fbFile# file. This is usually caused by unmatched XML tags (a &lt;tag&gt; without a &lt;/tag&gt; or without use of the &lt;tag/&gt; short-cut.)"
							extendedinfo="#cfcatch.detail#" />
				</cfcatch>
				
			</cftry>
			
			<cfif fbCode.xmlRoot.xmlName is not "fusebox">
				<cfthrow type="fusebox.badGrammar.badFuseboxFile"
						detail="Fusebox file does contain 'fusebox' XML" 
						message="Fusebox file #fbFile# does not contain 'fusebox' as the root XML node." />
			</cfif>

			<cfset loadParameters(fbCode) />
			<cfset loadLexicons(fbCode) />
			<cfset loadClasses(fbCode) />
			<cfset loadPlugins(fbCode) />
			<cfset loadGlobalPreAndPostProcess(fbCode) />
			<!--- save fusebox.xml DOM internally for (re-)loading circuits --->
			<cfset variables.fbCode = fbCode />
			<cfset variables.fbFile = fbFile />
			<cfset this.timestamp = now() />
		</cfif>
		
		<!--- to track circuit loads on this request --->
		<cfparam name="request.__fusebox.CircuitsLoaded" default="#structNew()#" />		
		<cfset loadCircuits(variables.fbCode,arguments.myFusebox) />
		
		<!--- FB5: fusebox.loadclean will delete all the parsed files --->
		<cfif arguments.myFusebox.parameters.clean>
			<cfset deleteParsedFiles() />
		</cfif>
		
		<!--- application data available to developers via getApplicationData() method: --->
		<cfset variables.data = structNew() />
		
		<cfset this.isFullyLoaded = true />
		<cfset this.applicationStarted = false />
		<cfset this.dateLastLoaded = now() />
		
		<!---
			The following documented parts of application.fusebox are not supported in Fusebox 5:
			- application.fusebox.xml
			- application.fusebox.globalfuseactions.*
			- application.fusebox.circuits.*.xml
			- application.fusebox.circuits.preFuseaction.*
			- application.fusebox.circuits.postFuseaction.*
			- application.fusebox.circuits.*.fuseactions.*.xml
		--->
		
	</cffunction>
	
	<cffunction name="getPluginsPath" returntype="string" access="public" output="false" 
				hint="I am a convenience method to return the location of the plugins.">
	
		<cfreturn this.pluginsPath />
	
	</cffunction>
	
	<cffunction name="getApplicationData" returntype="struct" access="public" output="false" 
				hint="I return a reference to the application data cache. This is a new concept in Fusebox 5.">
	
		<cfreturn variables.data />
	
	</cffunction>
	
	<cffunction name="getApplicationRoot" returntype="any" access="public" output="false" 
				hint="I am a convenience method to return the full application root directory path.">
	
		<cfreturn this.approotdirectory />
	
	</cffunction>
	
	<cffunction name="expandFuseboxPath" returntype="any" access="public" output="false" 
				hint="I expand a path in the context of a Fusebox application.">
		<cfargument name="partialPath" type="any" required="true" 
					hint="I am the partial path to expand. If I do not begin with a /, prepend the Fusebox application root." />

		<cfif left(arguments.partialPath,1) is "/">
			<!--- absolute path, i.e., root-relative or mapped --->
			<cfreturn replace(expandPath(arguments.partialPath),"\","/","all") />
		<cfelse>
			<!--- relative, i.e., relative to the Fusebox application root --->
			<cfreturn getApplicationRoot() & arguments.partialPath />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getFuseboxXMLFilename" returntype="string" access="public" output="false" 
				hint="I return the actual name of the fusebox.xml(.cfm) file.">
	
		<cfreturn variables.fbFile />
	
	</cffunction>
	
	<cffunction name="getCoreToAppRootPath" returntype="any" access="public" output="false" 
				hint="I am a convenience method to return the relative path from the core files to the application root.">
	
		<cfreturn this.coreToAppRootPath />
	
	</cffunction>
	
	<cffunction name="compileAll" returntype="void" access="public" output="false" 
				hint="I compile all the public fuseactions in the application.">
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />

		<cfset var c = 0 />
		<cfset var a = 0 />
		<cfset var f = 0 />
	
		<cfloop collection="#this.circuits#" item="c">
			<cfset a = this.circuits[c].getFuseactions() />
			<cfloop collection="#a#" item="f">
				<cfif a[f].access is "public">
					<cfset compileRequest(c & "." & f,arguments.myFusebox) />
				</cfif>
			</cfloop>
		</cfloop>

	</cffunction>
	
	<cffunction name="compileRequest" returntype="struct" access="public" output="false" 
				hint="I compile a specific (public) fuseaction as an external request.">
		<cfargument name="circuitFuseaction" type="string" required="true" 
					hint="I am the full name of the requested fuseaction (circuit.fuseaction)." />
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />

		<cfset var myVersion = getVersion() />
		<cfset var circuit = listFirst(arguments.circuitFuseaction,".") />
		<cfset var fuseaction = listLast(arguments.circuitFuseaction,".") />
		<cfset var i = 0 />
		<cfset var n = 0 />
		<cfset var needRethrow = true />
		<cfset var needTryOnFuseaction = false />
		<cfset var parsedName = "#lCase(arguments.circuitFuseaction)#.cfm" />
		<cfset var parsedFile = "#this.parsePath##parsedName#" />
		<cfset var fullParsedFile = "#this.expandFuseboxPath(this.parsePath)##parsedName#" />
		<cfset var result = structNew() />
		<cfset var writer = 0 />
		
		<!--- validate format of the fuseaction: --->
		<cfif listLen(arguments.circuitFuseaction,".") neq 2>
			<cfthrow type="fusebox.malformedFuseaction" 
					message="malformed Fuseaction" 
					detail="You specified a malformed Fuseaction of #arguments.circuitFuseaction#. A fully qualified Fuseaction must be in the form [Circuit].[Fuseaction]." />	
		</cfif>
		
		<!--- to track reloads on this request --->
		<cfparam name="request.__fusebox.CircuitsLoaded" default="#structNew()#" />
		<cfparam name="request.__fusebox.fuseactionsDone" default="#structNew()#" />
		
		<!--- set up myFusebox values for this request: --->
		<cfset arguments.myFusebox.originalCircuit = circuit />
		<cfset arguments.myFusebox.originalFuseaction = fuseaction />
		<cfloop collection="#this.plugins#" item="i">
			<cfset arguments.myFusebox.plugins[i] = structNew() />
		</cfloop>

		<!--- note that in Fusebox 5, these are really all the same set of files --->
		<cfset arguments.myFusebox.version.loader = myVersion />
		<cfset arguments.myFusebox.version.parser = myVersion />
		<cfset arguments.myFusebox.version.transformer = myVersion />
		<!--- legacy test from FB41 although it's a bit pointless --->
		<cfif myFusebox.version.runtime neq myFusebox.version.loader>
			<cfthrow type="fusebox.versionMismatchException"
					message="The loader is not the same version as the runtime" />
		</cfif>
		
		<!--- check access on request - if the circuit/fuseaction doesn't exist we trap it later --->
		<cfif structKeyExists(this.circuits,circuit) and 
				structKeyExists(this.circuits[circuit].fuseactions,fuseaction) and
				this.circuits[circuit].fuseactions[fuseaction].getAccess() is not "public">
			<cfthrow type="fusebox.invalidAccessModifier" 
					message="Invalid Access Modifier" 
					detail="You tried to access #circuit#.#fuseaction# which does not have access modifier of public. A Fuseaction which is to be accessed from anywhere outside the application (such as called via an URL, or a FORM, or as a web service) must have an access modifier of public or if unspecified at least inherit such a modifier from its circuit.">
		</cfif>
		
		<cfif not fileExists(fullParsedFile) or arguments.myFusebox.parameters.parse>
			<cflock name="#fullParsedFile#" type="exclusive" timeout="300">
				<cfif not fileExists(fullParsedFile) or arguments.myFusebox.parameters.parse>
					<cfset request.__fusebox.SuppressPlugins = false />
					<cfset writer = createObject("component","fuseboxWriter").init(this,arguments.myFusebox) />
					<cfset writer.open(parsedName) />
					<cfset writer.rawPrintln("<!--- circuit: #circuit# --->") />
					<cfset writer.rawPrintln("<!--- fuseaction: #fuseaction# --->") />
					<cfset writer.rawPrintln("<cftry>") />
					<cfset writer.setCircuit(circuit) />
					<cfset writer.setFuseaction(fuseaction) />
					<cfif variables.hasProcess["appinit"]>
						<cfset writer.setPhase("appinit") />
						<cfset writer.println("<cfif myFusebox.applicationStart>") />
						<cfset writer.println('	<cfif not myFusebox.getApplication().applicationStarted>') />
						<cfset writer.println('		<cflock name="##application.ApplicationName##_fusebox_##FUSEBOX_APPLICATION_KEY##_appinit" type="exclusive" timeout="30">') />
						<cfset writer.println('			<cfif not myFusebox.getApplication().applicationStarted>') />
						<cfset request.__fusebox.SuppressPlugins = true />
						<cfset variables.process["appinit"].compile(writer) />
						<cfset writer.println('				<cfset myFusebox.getApplication().applicationStarted = true />') />
						<cfset writer.println('			</cfif>') />
						<cfset writer.println('		</cflock>') />
						<cfset writer.println('	</cfif>') />
						<cfset writer.println("</cfif>") />
					</cfif>
					<cfset request.__fusebox.SuppressPlugins = false />
					<cfif structKeyExists(this.pluginPhases,"preProcess")>
						<cfset n = arrayLen(this.pluginPhases["preProcess"]) />
						<cfloop from="1" to="#n#" index="i">
							<cfset this.pluginPhases["preProcess"][i].compile(writer) />
						</cfloop>
					</cfif>
					<cfset writer.setPhase("preprocessFuseactions") />
					<cfif variables.hasProcess["preprocess"]>
						<cfset variables.process["preprocess"].compile(writer) />
					</cfif>
					<cfif structKeyExists(this.pluginPhases,"fuseactionException") and
							arrayLen(this.pluginPhases["fuseactionException"]) gt 0 and
							not request.__fusebox.SuppressPlugins>
						<cfset needTryOnFuseaction = true />
						<cfset writer.rawPrintln("<cftry>") />
					</cfif>
					<cfif structKeyExists(this.pluginPhases,"preFuseaction")>
						<cfset n = arrayLen(this.pluginPhases["preFuseaction"]) />
						<cfloop from="1" to="#n#" index="i">
							<cfset this.pluginPhases["preFuseaction"][i].compile(writer) />
						</cfloop>
					</cfif>
					<cfset writer.setPhase("requestedFuseaction") />
					<cfset compile(writer,circuit,fuseaction) />
					<cfif structKeyExists(this.pluginPhases,"postFuseaction")>
						<cfset n = arrayLen(this.pluginPhases["postFuseaction"]) />
						<cfloop from="1" to="#n#" index="i">
							<cfset this.pluginPhases["postFuseaction"][i].compile(writer) />
						</cfloop>
					</cfif>
					<cfif needTryOnFuseaction>
						<cfset n = arrayLen(this.pluginPhases["fuseactionException"]) />
						<cfloop from="1" to="#n#" index="i">
							<cfset this.pluginPhases["fuseactionException"][i].compile(writer) />
						</cfloop>
						<cfset writer.rawPrintln("</cftry>") />
					</cfif>
					<cfset writer.setPhase("postprocessFuseactions") />
					<cfif variables.hasProcess["postprocess"]>
						<cfset variables.process["postprocess"].compile(writer) />
					</cfif>
					<cfif structKeyExists(this.pluginPhases,"postProcess")>
						<cfset n = arrayLen(this.pluginPhases["postProcess"]) />
						<cfloop from="1" to="#n#" index="i">
							<cfset this.pluginPhases["postProcess"][i].compile(writer) />
						</cfloop>
					</cfif>
					<cfif structKeyExists(this.pluginPhases,"processError") and
							not request.__fusebox.SuppressPlugins>
						<cfset n = arrayLen(this.pluginPhases["processError"]) />
						<cfloop from="1" to="#n#" index="i">
							<cfset needRethrow = false />
							<cfset this.pluginPhases["processError"][i].compile(writer) />
						</cfloop>
					</cfif>
					<cfif needRethrow>
						<cfset writer.rawPrintln('<' & 'cfcatch><' & 'cfrethrow><' & '/cfcatch>') />
					</cfif>
					<cfset writer.rawPrintln("</cftry>") />
					<cfset writer.close() />
				</cfif>
			</cflock>
		</cfif>
		
		<cfset result.parsedName = parsedName />
		<cfif left(parsedFile,1) is "/">
			<cfset result.parsedFile = parsedFile />
		<cfelse>
			<cfset result.parsedFile = this.getCoreToAppRootPath() & parsedFile />
		</cfif>
		<cfset result.lockName = fullParsedFile />
		
		<cfreturn result />
		
	</cffunction>
	
	<cffunction name="compile" returntype="void" access="public" output="false" 
				hint="I compile a specific fuseaction during a request (such as for a 'do' verb).">
		<cfargument name="writer" type="any" required="false" 
					hint="I am the parsed file writer object. I am required but it's faster to specify that I am not required." />
		<cfargument name="circuit" type="any" required="false" 
					hint="I am the circuit name. I am required but it's faster to specify that I am not required." />
		<cfargument name="fuseaction" type="any" required="false" 
					hint="I am the fuseaction name, within the specified circuit." />
	
		<cfset var c = "" />

		<cfif not structKeyExists(this.circuits,arguments.circuit)>
			<cfthrow type="fusebox.undefinedCircuit" 
					message="undefined Circuit" 
					detail="You specified a Circuit of #arguments.circuit# which is not defined." />
		</cfif>
		<!--- FB5: development-circuit-load only reloads the requested circuit --->
		<cfif this.mode is "development-circuit-load">
			<!--- FB5: ensure we only reload each circuit once per request --->
			<cfif not structKeyExists(request.__fusebox.CircuitsLoaded,arguments.circuit)>
				<cfset request.__fusebox.CircuitsLoaded[arguments.circuit] = true />
				<cfset this.circuits[arguments.circuit].reload(arguments.writer.getMyFusebox()) />
			</cfif>
		</cfif>
	
		<cfset c = arguments.writer.setCircuit(arguments.circuit) />
		<cfset this.circuits[arguments.circuit]
				.compile(arguments.writer,arguments.fuseaction) />
		<cfset arguments.writer.setCircuit(c) />
		
	</cffunction>
	
	<cffunction name="handleFuseboxException" returntype="boolean" access="public" output="true" 
				hint="I attempt to handle a Fusebox exception by looking for a handler file in the errortemplates/ directory. I return true if I handle the exception, else I return false.">
		<cfargument name="cfcatch" type="any" required="true" 
					hint="I am the original cfcatch structure from the exception that fusebox5.cfm caught." />
		<cfargument name="attributes" type="struct" required="true" 
					hint="I am the attributes 'scope'." />
		<cfargument name="myFusebox" type="any" required="true" 
					hint="I am the myFusebox object." />
		<cfargument name="appKey" type="string" required="true" 
					hint="I am the application key object." />
		
		<cfset var __handled = false />
		<cfset var __type = arguments.cfcatch.type />
		<cfset var __ext = "." & this.scriptFileDelimiter />
		<cfset var __errorFile = this.errortemplatesPath & __type & __ext />
		<cfset var __handlerExists = fileExists(expandFuseboxPath(__errorFile)) />
		<cfset var FUSEBOX_APPLICATION_KEY = arguments.appKey />
		
		<cfloop condition="not __handlerExists and len(__type) gt 0">
			<cfset __type = listDeleteAt(__type,listLen(__type,"."),".") />
			<cfset __errorFile = this.errortemplatesPath & __type & __ext />
			<cfset __handlerExists = fileExists(expandFuseboxPath(__errorFile)) />
		</cfloop>
		<cfif __handlerExists>
			<cfif left(__errorFile,1) is "/">
				<cfinclude template="#__errorFile#" />
			<cfelse>
				<cfinclude template="#getCoreToAppRootPath()##__errorFile#" />
			</cfif>
			<cfset __handled = true />
		</cfif>
		
		<cfreturn __handled />
		
	</cffunction>
	
	<cffunction name="getFuseactionFactory" returntype="any" access="public" output="false" 
				hint="I return the factory object that makes fuseaction objects for the framework.">
		
		<cfreturn variables.factory />

	</cffunction>
	
	<cffunction name="getClassDefinition" returntype="struct" access="public" output="false" 
				hint="I return the class declaration for a given class. I throw an exception if the class has no declaration.">
		<cfargument name="className" type="string" required="true" 
					hint="I am the name of the class whose declaration should be returned." />
		
		<cfreturn this.classes[arguments.className] />

	</cffunction>
	
	<cffunction name="getLexiconDefinition" returntype="any" access="public" output="false" 
				hint="I return the lexicon definition for a given namespace. I return either the internal Fusebox lexicon or a declared (Fusebox 4.1 style) lexicon.">
		<cfargument name="namespace" type="any" required="false" 
					hint="I am the namespace of the lexicon whose definition should be returned. I am required but it's faster to specify that I am not required." />
		
		<cfif arguments.namespace is variables.fuseboxLexicon.namespace>
			<cfreturn variables.fuseboxLexicon />
		<cfelse>
			<cfreturn variables.fb41Lexicons[arguments.namespace] />
		</cfif>

	</cffunction>
	
	<cffunction name="getVersion" returntype="string" access="public" output="false" 
				hint="I return the version of this Fusebox 5 object. This is the preferred way to obtain the version in Fusebox 5.">
	
		<cfreturn variables.fuseboxVersion />
		
	</cffunction>
	
	<cffunction name="getAlias" returntype="any" access="public" output="false" 
				hint="I return the fake circuit alias for the application.">
	
		<cfreturn "$fusebox" />
	
	</cffunction>
	
	<cffunction name="getApplication" returntype="any" access="public" output="false" 
				hint="I return the fusebox application object.">
	
		<cfreturn this />
	
	</cffunction>
	
	<cffunction name="getCustomAttributes" returntype="struct" access="public" output="false" 
				hint="I return any custom attributes for the specified namespace prefix.">
		<cfargument name="ns" type="string" required="true" 
					hint="I am the namespace for which to return custom attributes." />
		
		<cfif structKeyExists(variables.customAttributes,arguments.ns)>
			<!--- we structCopy() this so folks can't poke values back into the metadata! --->
			<cfreturn structCopy(variables.customAttributes[arguments.ns]) />
		<cfelse>
			<cfreturn structNew() />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getFuseboxFileExtension" returntype="string" access="public" output="false" 
				hint="I return the fusebox.xml file extension: either xml or cfm.">
					
		<cfreturn variables.fuseboxFileExtension />
		
	</cffunction>
	
	<cffunction name="deleteParsedFiles" returntype="void" access="private" output="false" 
				hint="I delete all the script files in the parsed/ directory.">
	
		<cfset var fileQuery = 0 />
		<cfset var parseDir = expandFuseboxPath(this.parsePath) />
		
		<cftry>
			<cfdirectory action="list" directory="#parseDir#" 
						filter="*.#this.scriptFileDelimiter#" name="fileQuery" />
			<cfloop query="fileQuery">
				<cffile action="delete" file="#parseDir##fileQuery.name#" />
			</cfloop>
		<cfcatch />
		</cftry>
	
	</cffunction>
	
	<cffunction name="loadCircuits" returntype="void" access="private" output="false" 
				hint="I (re)load all the circuits in an application.">
		<cfargument name="fbCode" type="any" required="true" 
					hint="I am the parsed XML representation of the fusebox.xml file." />
		<cfargument name="myFusebox" type="myFusebox" required="true" 
					hint="I am the myFusebox data structure." />
		
		<cfset var children = xmlSearch(arguments.fbCode,"/fusebox/circuits/circuit") />
		<cfset var i = 0 />
		<cfset var n = arrayLen(children) />
		<cfset var previousCircuits = this.circuits />
		<cfset var alias = "" />
		<cfset var parent = "" />
		<cfset var relative = true />
		<cfset var nAttrs = 0 />
		
		<cfset this.circuits = structNew() />
		
		<!--- pass 1: build the circuits --->
		<cfloop from="1" to="#n#" index="i">
			<cfif not structKeyExists(children[i].xmlAttributes,"alias")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'alias' is required, for a 'circuit' declaration in fusebox.xml." />
			</cfif>
			<cfif not structKeyExists(children[i].xmlAttributes,"path")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'path' is required, for the declaration of circuit '#children[i].xmlAttributes.alias#' in fusebox.xml." />
			</cfif>
			<cfif structKeyExists(children[i].xmlAttributes,"parent")>
				<cfset parent = children[i].xmlAttributes.parent />
				<cfset nAttrs = 3 />
			<cfelse>
				<cfset parent = "" />
				<cfset nAttrs = 2 />
			</cfif>
			<cfif structKeyExists(children[i].xmlAttributes,"relative")>
				<cfif listFind("true,false,yes,no",children[i].xmlAttributes.relative) eq 0>
					<cfthrow type="fusebox.badGrammar.invalidAttributeValue"
							message="Attribute has invalid value" 
							detail="The attribute 'relative' must either be ""true"" or ""false"", for the declaration of circuit '#children[i].xmlAttributes.alias#' in fusebox.xml." />
				</cfif>
				<cfset relative = children[i].xmlAttributes.relative />
				<cfset nAttrs = nAttrs + 1 />
			<cfelse>
				<cfset relative = true />
			</cfif>
			<cfif this.strictMode and nAttrs neq structCount(children[i].xmlAttributes)>
				<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
						message="Unexpected attributes"
						detail="Attributes other than 'alias', 'path' and 'parent' were found for the declaration of circuit '#children[i].xmlAttributes.alias#' in fusebox.xml." />
			</cfif>
			<cfset alias = children[i].xmlAttributes.alias />
			<!--- record each circuit load per request - optimization for development-circuit-load mode --->
			<cfset request.__fusebox.CircuitsLoaded[alias] = true />
			<cfif structKeyExists(previousCircuits,alias) and
					children[i].xmlAttributes.path is previousCircuits[alias].getOriginalPath() and
					parent is previousCircuits[alias].parent and
					relative eq previousCircuits[alias].getOriginalPathIsRelative()>
				<!--- old circuit, we can just reload it --->
				<cfset this.circuits[alias] = previousCircuits[alias].reload(arguments.myFusebox) />
			<cfelse>
				<!--- new circuit, we must create it from scratch --->
				<cfset this.circuits[alias] =
						createObject("component","fuseboxCircuit")
							.init(this,alias,children[i].xmlAttributes.path,parent,arguments.myFusebox,relative) />
			</cfif>
		</cfloop>
		
		<!--- pass 2: build the circuit trace for each circuit --->
		<cfloop collection="#this.circuits#" item="i">
			<cfset this.circuits[i].buildCircuitTrace() />
		</cfloop>
		
	</cffunction>
	
	<cffunction name="loadLexicons" returntype="void" access="private" output="false" 
				hint="I load any lexicon declarations (both the Fusebox 4.1 style lexicon declarations and the Fusebox 5 style namespace declarations).">
		<cfargument name="fbCode" type="any" required="true" 
					hint="I am the parsed XML representation of the fusebox.xml file." />
		
		<cfset var children = xmlSearch(arguments.fbCode,"/fusebox/lexicons/lexicon") />
		<cfset var i = 0 />
		<cfset var n = arrayLen(children) />
		<cfset var aLex = "" />
		<cfset var attributes = arguments.fbCode.xmlRoot.xmlAttributes />
		<cfset var attr = "" />
		<cfset var ns = "" />
		
		<cfif n gt 0 and this.strictMode>
			<cfthrow type="fusebox.badGrammar.deprecated" 
					message="Deprecated feature"
					detail="Using the 'lexicon' declaration in fusebox.xml was deprecated in Fusebox 5." />
		</cfif>

		<!--- load the legacy FB41 lexicons from the XML --->
		<cfset variables.fb41Lexicons = structNew() />
		
		<cfloop from="1" to="#n#" index="i">
			<cfset aLex = structNew() />
			<cfset aLex.namespace = children[i].xmlAttributes.namespace />
			<cfset aLex.path = normalizePartialPath(children[i].xmlAttributes.path) />
			<!--- FB41 lexicons are deprecated so we don't support absolute / mapped paths: --->
			<cfset aLex.path = getCoreToAppRootPath() & this.lexiconPath & aLex.path />
			<cfset variables.fb41Lexicons[children[i].xmlAttributes.namespace] = aLex />
		</cfloop>
		
		<!--- now load the new FB5 implicit lexicons from the <fusebox> tag --->
		<cfset variables.lexicons = structNew() />
		
		<!--- pass 1: pull out any namespace declarations --->
		<cfloop collection="#attributes#" item="attr">
			<cfif len(attr) gt 6 and left(attr,6) is "xmlns:">
				<!--- found a namespace declaration, pull it out: --->
				<cfset aLex = structNew() />
				<cfset aLex.namespace = listLast(attr,":") />
				<cfif aLex.namespace is variables.fuseboxLexicon.namespace>
					<cfthrow type="fusebox.badGrammar.reservedName"
							message="Attempt to use reserved namespace" 
							detail="You have attempted to declare a namespace '#aLex.namespace#' (in fusebox.xml) which is reserved by the Fusebox framework." />
				</cfif>
				<cfset attributes[attr] = normalizePartialPath(attributes[attr]) />
				<cfif left(attributes[attr],1) is "/">
					<!--- assume mapped / root-relative path --->
					<cfset aLex.path = attributes[attr] />
				<cfelseif left(this.lexiconPath,1) is "/">
					<!--- assume mapped / root-relative path --->
					<cfset aLex.path = this.lexiconPath & attributes[attr] />
				<cfelse>
					<!--- relative paths --->
					<cfset aLex.path = getCoreToAppRootPath() & 
							this.lexiconPath & attributes[attr] />
				</cfif>
				<cfset variables.lexicons[aLex.namespace] = aLex />
				<cfset variables.customAttributes[aLex.namespace] = structNew() />
			</cfif>
		</cfloop>
		
		<!--- pass 2: pull out any custom attributes --->
		<cfloop collection="#attributes#" item="attr">
			<cfif listLen(attr,":") eq 2>
				<!--- looks like a custom attribute: --->
				<cfset ns = listFirst(attr,":") />
				<cfif ns is "xmlns">
					<!--- special case - need to ignore xmlns:foo="bar" --->
				<cfelseif structKeyExists(variables.customAttributes,ns)>
					<cfset variables.customAttributes[ns][listLast(attr,":")] = attributes[attr] />
				<cfelse>
					<cfthrow type="fusebox.badGrammar.undeclaredNamespace" 
							message="Undeclared lexicon namespace" 
							detail="The lexicon prefix '#ns#' was found on a custom attribute in the <fusebox> tag but no such lexicon namespace has been declared." />
				</cfif>
			<cfelseif this.strictMode>
				<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
						message="Unexpected attributes"
						detail="Unexpected attributes were found in the 'fusebox' tag in fusebox.xml." />
			</cfif>
		</cfloop>
		
	</cffunction>
	
	<cffunction name="loadClasses" returntype="void" access="private" output="false" 
				hint="I load any class declarations, including custom attributes (based on Fusebox 5 namespace declarations).">
		<cfargument name="fbCode" type="any" required="true" 
					hint="I am the parsed XML representation of the fusebox.xml file." />
		
		<cfset var children = xmlSearch(arguments.fbCode,"/fusebox/classes/class") />
		<cfset var i = 0 />
		<cfset var n = arrayLen(children) />
		<cfset var attribs = 0 />
		<cfset var attr = "" />
		<cfset var ns = "" />
		<cfset var customAttribs = 0 />
		<cfset var constructor = "" />
		<cfset var type = "" />
		<cfset var nAttrs = 0 />
		
		<cfset this.classes = structNew() />
		
		<cfloop from="1" to="#n#" index="i">
			<cfset attribs = children[i].xmlAttributes />

			<cfif not structKeyExists(attribs,"alias")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'alias' is required, for a 'class' declaration in fusebox.xml." />
			</cfif>
			<cfif not structKeyExists(attribs,"classpath")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'classpath' is required, for a 'class' declaration in fusebox.xml." />
			</cfif>
			<cfif structKeyExists(attribs,"constructor")>
				<cfset constructor = attribs.constructor />
				<cfset nAttrs = 3 />
			<cfelse>
				<cfset constructor = "" />
				<cfset nAttrs = 2 />
			</cfif>
			<!--- FB5: allow sensible default for type --->
			<cfif structKeyExists(attribs,"type")>
				<cfset type = attribs.type />
				<cfset nAttrs = nAttrs + 1 />
			<cfelse>
				<cfset type = "component" />
			</cfif>

			<!--- scan for custom attributes --->
			<cfset customAttribs = structNew() />
			<cfloop collection="#attribs#" item="attr">
				<cfif listLen(attr,":") eq 2>
					<cfset nAttrs = nAttrs + 1 />
					<!--- looks like a custom attribute: --->
					<cfset ns = listFirst(attr,":") />
					<cfif structKeyExists(variables.customAttributes,ns)>
						<cfset customAttribs[ns][listLast(attr,":")] = attribs[attr] />
					<cfelse>
						<cfthrow type="fusebox.badGrammar.undeclaredNamespace" 
								message="Undeclared lexicon namespace" 
								detail="The lexicon prefix '#ns#' was found on a custom attribute in the <class> tag but no such lexicon namespace has been declared." />
					</cfif>
				</cfif>
			</cfloop>
			
			<cfif this.strictMode and structCount(attribs) neq nAttrs>
				<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
						message="Unexpected attributes"
						detail="Unexpected attributes were found in the '#attribs.alias#' class declaration in fusebox.xml." />
			</cfif>

			<cfset this.classes[attribs.alias] = createObject("component","fuseboxClassDefinition")
								.init(type,attribs.classpath,constructor,customAttribs) />
			
		</cfloop>
		
	</cffunction>
	
	<cffunction name="loadPlugins" returntype="void" access="private" output="false" 
				hint="I load any plugin declarations.">
		<cfargument name="fbCode" type="any" required="true" 
					hint="I am the parsed XML representation of the fusebox.xml file." />
		
		<!--- TODO: this xpath means that we can't spot bad phase declarations: --->
		<cfset var children = xmlSearch(arguments.fbCode,"/fusebox/plugins/phase") />
		<cfset var i = 0 />
		<cfset var n = arrayLen(children) />
		<cfset var j = 0 />
		<cfset var nn = 0 />
		<cfset var phase = "" />
		<cfset var plugin = 0 />
		
		<cfset this.plugins = structNew() />
		<cfset this.pluginphases = structNew() />
		
		<cfloop from="1" to="#n#" index="i">
			<cfif not structKeyExists(children[i].xmlAttributes,"name")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'name' is required, for a 'plugin' declaration in fusebox.xml." />
			</cfif>
			<cfset phase = children[i].xmlAttributes.name />
			<cfif this.strictMode and structCount(children[i].xmlAttributes) neq 1>
				<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
						message="Unexpected attributes"
						detail="Unexpected attributes were found in the '#phase#' phase declaration in fusebox.xml." />
			</cfif>
			<cfset nn = arrayLen(children[i].xmlChildren) />
			<cfloop from="1" to="#nn#" index="j">
				<cfset plugin = createObject("component","fuseboxPlugin").init(phase,children[i].xmlChildren[j],this,variables.lexicons) />
				<cfset this.plugins[plugin.getName()][phase] = plugin />
				<cfif not structKeyExists(this.pluginphases,phase)>
					<cfset this.pluginphases[phase] = arrayNew(1) />
				</cfif>
				<cfset arrayAppend(this.pluginphases[phase],plugin) />
			</cfloop>
		</cfloop>
		
	</cffunction>
	
	<cffunction name="loadParameters" returntype="void" access="private" output="false" 
				hint="I load any parameter declarations (and ensure none of them can overwrite public methods in this object!).">
		<cfargument name="fbCode" type="any" required="true" 
					hint="I am the parsed XML representation of the fusebox.xml file." />
		
		<cfset var children = xmlSearch(arguments.fbCode,"/fusebox/parameters/parameter") />
		<cfset var i = 0 />
		<cfset var n = arrayLen(children) />
		<cfset var p = "" />
		
		<cfloop from="1" to="#n#" index="i">
			<cfif not structKeyExists(children[i].xmlAttributes,"name")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'name' is required, for a 'parameter' declaration in fusebox.xml." />
			</cfif>
			<cfset p = children[i].xmlAttributes.name />
			<cfif not structKeyExists(children[i].xmlAttributes,"value")>
				<cfthrow type="fusebox.badGrammar.requiredAttributeMissing"
						message="Required attribute is missing"
						detail="The attribute 'value' is required, for the '#p#' parameter declaration in fusebox.xml." />
			</cfif>
			<cfif this.strictMode and structCount(children[i].xmlAttributes) neq 2>
				<cfthrow type="fusebox.badGrammar.unexpectedAttributes"
						message="Unexpected attributes"
						detail="Unexpected attributes were found in the '#p#' parameter declaration in fusebox.xml." />
			</cfif>
			<cfif structKeyExists(this,p) and isCustomFunction(this[p])>
				<cfthrow type="fusebox.badGrammar.reservedName"
						message="Attempt to use reserved parameter name"
						detail="You have attempted to set a parameter called '#p#' which is reserved by the Fusebox framework." />
			<cfelse>
				<cfset this[p] = children[i].xmlAttributes.value />
			</cfif>
		</cfloop>
		
		<!---
			if the user overrides certain path variables, we need to normalize them:
			- this.parsePath (reset parseRootPath)
			- this.pluginsPath
			- this.lexiconPath
			- this.errortemplatesPath
			normalizing means changing all \ to / and appending / if not present
		--->
		<cfset this.parsePath = normalizePartialPath(this.parsePath) />
		<cfset this.parseRootPath = relativePath(expandFuseboxPath(this.parsePath),getApplicationRoot()) />
		<cfset this.pluginsPath = normalizePartialPath(this.pluginsPath) />
		<cfset this.lexiconPath = normalizePartialPath(this.lexiconPath) />
		<cfset this.errortemplatesPath = normalizePartialPath(this.errortemplatesPath) />
		
		<!--- Fusebox 5.1: default this.myself: --->
		<cfif not structKeyExists(this,"myself")>
			<cfset this.myself = getDefaultMyself(this.self) />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getDefaultMyself" returntype="string" access="public" output="false" 
				hint="I return the default value of 'myself' for a given value of 'self'.">
		<cfargument name="self" type="string" required="true" 
					hint="I am the value of 'self' to use." />
		
		<cfreturn arguments.self & this.queryStringStart & this.fuseactionVariable & this.queryStringEqual />
		
	</cffunction>
		
	<cffunction name="loadGlobalProcess" returntype="void" access="private" output="false" 
				hint="I load the globalfuseaction for the specified processing phase.">
		<cfargument name="fbCode" type="any" required="true" 
					hint="I am the parsed XML representation of the fusebox.xml file." />
		<cfargument name="processPhase" type="string" required="true" 
					hint="I am the name of the processing phase to load (appinit, preprocess or postprocess)." />
		
		<cfset var children = xmlSearch(arguments.fbCode,"/fusebox/globalfuseactions/#arguments.processPhase#") />
		<cfset var n = arrayLen(children) />
		
		<cfif n eq 0>
			<cfset variables.hasProcess[arguments.processPhase] = false />
		<cfelseif n eq 1>
			<cfset variables.hasProcess[arguments.processPhase] = true />
			<cfset variables.process[arguments.processPhase] =
					createObject("component","fuseboxAction")
						.init(this,
							"$globalfuseaction/#arguments.processPhase#",
								"internal",
									children[1].xmlChildren,true) />
		<cfelse>
			<cfthrow type="fusebox.badGrammar.nonUniqueDeclaration" 
					message="Declaration was not unique" 
					detail="More than one &lt;#arguments.process#&gt; declaration was found in the &lt;globalfuseactions&gt; section in fusebox.xml." />
		</cfif>
		
	</cffunction>
	
	<cffunction name="loadGlobalPreAndPostProcess" returntype="void" access="private" output="false" 
				hint="I load any globalfuseaction declarations.">
		<cfargument name="fbCode" type="any" required="true" 
					hint="I am the parsed XML representation of the fusebox.xml file." />
		
		<cfset var children = xmlSearch(arguments.fbCode,"/fusebox/globalfuseactions/*") />
		<cfset var i = 0 />
		<cfset var n = arrayLen(children) />
		
		<cfloop index="i" from="1" to="#n#">
			<cfif listFind("appinit,preprocess,postprocess",children[i].xmlName) eq 0>
				<cfthrow type="fusebox.badGrammar.illegalDeclaration"
						message="Illegal declaration"
						detail="The tag '#children[i].xmlName#' was found where 'appinit', 'preprocess' or 'postprocess' was expected in the &lt;globalfuseactions&gt; section in fusebox.xml." />
			</cfif>
		</cfloop>

		<cfset variables.hasProcess = structNew() />
		<cfset variables.process = structNew() />
		<cfset loadGlobalProcess(arguments.fbCode,"appinit") />
		<cfset loadGlobalProcess(arguments.fbCode,"preprocess") />
		<cfset loadGlobalProcess(arguments.fbCode,"postprocess") />
		
	</cffunction>
	
	<cffunction name="relativePath" returntype="string" access="public" output="false" 
				hint="I compute the relative path from one file system location to another.">
		<cfargument name="from" type="string" required="true" 
					hint="I am the full pathname from which the relative path should be computed." />
		<cfargument name="to" type="string" required="true" 
					hint="I am the full pathname to which the relative path should be computed." />
		
		<cfset var relative = "" />
		<cfset var fromFirst = listFirst(arguments.from,"/") />
		<cfset var fromRest = arguments.from />
		<cfset var toFirst = listFirst(arguments.to,"/") />
		<cfset var toRest = arguments.to />
		<cfset var needSlash = false />
		
		<!--- trap special case first --->
		<cfif arguments.from is arguments.to>
			<cfreturn "" />
		</cfif>
	
		<!--- walk down the common part of the paths --->
		<cfloop condition="fromFirst is toFirst">
			<cfset needSlash = true />
			<cfset fromRest = listRest(fromRest,"/") />
			<cfset toRest = listRest(toRest,"/") />
			<cfset fromFirst = listFirst(fromRest,"/") />
			<cfset toFirst = listFirst(toRest,"/") />
		</cfloop>	
		<!--- at this point the paths differ --->
		<cfif not needSlash>
			<!--- the paths differed from the top so we need to strip the leading / --->
			<cfset toRest = right(toRest,len(toRest)-1) />
		</cfif>
		<cfset relative = repeatString("../",listLen(fromRest,"/")) & toRest />
		<!---
			ensure the trailing / is present - strictly speaking this is a bug fix for Railo
			but it's probably a good practice anyway
		--->
		<cfif right(relative,1) is not "/">
			<cfset relative = relative & "/" />
		</cfif>

		<cfreturn relative />
		
	</cffunction>
	
	<cffunction name="getCanonicalPath" returntype="string" access="public" output="false" 
				hint="I return a canonical file path (with all /../ sections resolved).">
		<cfargument name="path" type="string" required="true" 
					hint="I am the path to resolve." />
		
		<cfset var resolvedPath = arguments.path />
		<cfset var leadingSlash = left(resolvedPath,1) is "/" />
		<cfset var trailingSlash = right(resolvedPath,1) is "/" />
		<cfset var segment = ""/>
		<cfset var j = 1 />
		<cfset var n = 0 />
		<cfset var pathParts = arrayNew(1) />
		<cfset var delimiter = "" />

		<!--- remove pairs of directory/../ --->		
		<cfloop list="#resolvedPath#" delimiters="/" index="segment">
			<cfif segment is ".">
				<!--- just ignore this --->
			<cfelseif segment is "..">
				<cfif j gt 1 and pathParts[j-1] is not "..">
					<cfset j = j - 1 />
				<cfelse>
					<cfset pathParts[j] = segment />
					<cfset j = j + 1 />
				</cfif>
			<cfelse>
				<cfset pathParts[j] = segment />
				<cfset j = j + 1 />
			</cfif>
		</cfloop>
		
		<!--- rebuild the path --->
		<cfif leadingSlash>
			<cfset delimiter = "/" />
		</cfif>
		<cfset resolvedPath = "" />
		<cfset n = j - 1 />
		<cfloop from="1" to="#n#" index="j">
			<cfset resolvedPath = resolvedPath & delimiter & pathParts[j] />
			<cfset delimiter = "/" />
		</cfloop>
		<cfif trailingSlash>
			<cfset resolvedPath = resolvedPath & "/" />
		</cfif>

		<cfreturn resolvedPath />
		
	</cffunction>
	
	<cffunction name="normalizePartialPath" returntype="string" access="public" output="false" 
				hint="I return a normalized file path (that has / instead of \ and ends with /).">
		<cfargument name="partialPath" type="string" required="true" 
					hint="I am the path to normalize." />
		
		<cfset var unixPath = replace(arguments.partialPath,"\","/","all") />
		
		<cfif right(unixPath,1) is not "/">
			<cfset unixPath = unixPath & "/" />
		</cfif>
		
		<cfreturn unixPath />
		
	</cffunction>
	
</cfcomponent>
