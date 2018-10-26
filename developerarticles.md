/*https://developer.salesforce.com*/

/**/

/*Force.com Email Services  Email to Lead and Email to Case
Must implement the Messaging interface
Implemented a namespace “Messaging”
Additional input parameter “Messaging. InboundEnvelope”
New and improved security model
Uses Email Authentication protocols (SPF, SenderId, DomainKeys) to secure the email addresses*/

global class InboundMailHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                    Messaging.InboundEnvelope env){

        //email holds all the data related to mail                                               
        // Set the result to true, no need to send an email back to the user
        // with an error message
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;
        // Return the result for the Force.com Email Service
        return result;
    }
}

@isTest
public class InboundMailHandlerTest{
    static testMethod void testEmailProcess() {
        // Create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // Create the plainTextBody and fromAddres for the test
        email.plainTextBody = 'Here is my plainText body of the email';
        email.fromAddress ='rmencke@salesforce.com';

        InboundMailHandler imh = new InboundMailHandler();
        Messaging.InboundEnvelope result = imh.handleInboundEmail(email, env);

        System.assert(result.success,'Failed Email Process')
    } 
}

/*Check Subject Content 'unsubscribe;' then make contact and lead hasOptedOutOfEmail true*/

public static addFunctionality(){
    string fromAddres = env.fromAddres;
    string mailSubject = env.subject.toLowerCase();
    List<Contact> ContactLst = [Select Id, Name, Email, HasOptedOutOfEmail From Contact Where Email = :env.fromAddress AND And hasOptedOutOfEmail = false limit 100];

    List<Lead> leadtLst = [Select Id, Name, Email, HasOptedOutOfEmail From Lead Where Email = :env.fromAddress AND And hasOptedOutOfEmail = false AND isConverted=false limit 100];



}

/*Email Service with Attachment*/
Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
Messaging.InboundEmail email = new Messaging.InboundEmail();
email.subject = 'test';
env.fromAddress = 'user@acme.com';
// set the body of the attachment 
inAtt.body = blob.valueOf('test');
inAtt.fileName = 'my attachment name';
inAtt.mimeTypeSubType = 'plain/txt';
email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt};

Messaging.InboundEmail.BinaryAttachment inAtt  = email.binaryAttachments;

/*create Idea From Email */
Idea newIdea = new Idea();
newIdea.Title = email.subject;
newIdea.Body = email.plainTextBody;
insert Idea;

Controller Picklist
<apex:outputLabel value="Feature Category:" for="category"/>
<apex:selectList value="{!category}" size="1" id="category">
    <apex:selectOptions value="{!categories}"/>
</apex:selectList>

controlled picklist
<apex:selectList value="{!feature}" size="1" id="features" disabled="{!ISNULL(category)}">
    <apex:selectOptions value="{!features}"/>
</apex:selectList>

<apex:actionSupport event="onchange" rerender="features"/>



/*
    Google Data APIS
    https://developer.salesforce.com/blogs/developer-relations/2008/06/announcement-of.html
*/

//authenticate
CalendarService service = new CalendarService();  
service.setAuthSubToken(sessionAuthToken); 

<apex:page renderAs="{!if(asPdf,'pdf',null)}" controller="DisplayInPdfCC"  >
    <!--renderAs="{!if($CurrentPage.parameters.p == null, null, 'pdf')}"-->
    <apex:pageBlock title="My Dual-Rendering Invoice">
        <apex:pageBlockSection title="Section 1"> Text </apex:pageBlockSection>
        <apex:pageBlockSection title="Section 2"> Text </apex:pageBlockSection>
    </apex:pageBlock>
    <p>
        !asPdf : {!asPdf}
        $CurrentPage.parameters.key : {!$CurrentPage.parameters.key}
    </p>
    <apex:form >
        <apex:commandLink rendered="{!!asPdf && $CurrentPage.parameters.key == null}" value="viewAsPdf" action="{!viewAsPdf}"/> &nbsp;&nbsp;
        <apex:commandLink rendered="{!!asPdf && $CurrentPage.parameters.key == null}"  value="sendAsPDF" action="{!deliverAsPDF}" ></apex:commandLink>&nbsp;&nbsp;
        <apex:commandLink rendered="{!!asPdf && $CurrentPage.parameters.key == null}" value="SendAsExcel" action="{!DeliverAsExcel}"/> &nbsp;&nbsp;
    </apex:form>
</apex:page>

public class DisplayInPdfCC {
    
    public Boolean asPdf{get;private set;}
    public Boolean asXl{get;private set;}
    
    public PageReference viewAsXl(){
        asXl = true;
        return null;
    }
    
    public PageReference viewAsPdf(){
        asPdf = true;
        return null;
    }
    
    public PageReference DeliverAsPDF() {
        PageReference pdf =  Page.DisplayInPDf;
        //Reference the page, pass in a parameter to force PDF 
        pdf.getParameters().put('key','pdf');
        pdf.setRedirect(true);
        Blob b = pdf.getContentAsPDF();
        // Create an email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('From getDeliverAsPDF!');
        String [] toAddresses = new String[] {'sumitdreamforcedeveloper@gmail.com'};
            email.setToAddresses(toAddresses);
        email.setPlainTextBody('Here is the body of the email');
        // Create an email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('MyPDF.pdf'); // neat - set name of PDF
        efa.setBody(b); //attach the PDF
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        // send it, ignoring any errors (bad!)
        Messaging.SendEmailResult [] r =
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        return null;
    }
    
    public PageReference DeliverAsExcel(){
        //Build a email
        Messaging.singleEmailMessage email = new Messaging.singleEmailMessage();
        String [] toAddresses = new String[] {'sumitdreamforcedeveloper@gmail.com'};
            email.setToAddresses(toAddresses);
        email.setSubject('In Excel');
        email.setPlainTextBody('Excel Attachement'); 
        //Build an attachment
        Messaging.EmailFileAttachment attach_Xl = new Messaging.EmailFileAttachment();
        attach_Xl.setContentType('application/vnd.ms-excel');
        attach_Xl.setFileName('ExcelfileSC.xls');
        PageReference pg = Page.DisplayInPDf;
        pg.getParameters().put('key','Xl');
        pg.setRedirect(true);
        Blob excel = pg.getContent();
        attach_Xl.setBody(excel);
        //add attachment with email
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach_Xl});
        //send email with attachment
        Messaging.SendEmailResult [] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        System.debug('emailResult : '+emailResult);
        return null;
    }
}

<apex:component access="global" controller="orderedLineItems">
    <apex:attribute name="opportunityID" description="This is the ID of the oppotunity." type="ID" assignTo="{!opportunityID}" />
    <apex:dataTable value="{!lineItems}" var="l">
        <apex:column value="{!l.pricebookEntry.Name}"/>
        <apex:column value="{!l.Quantity}"/>
        <apex:column value="{!l.UnitPrice}"/>
        <apex:column value="{!l.TotalPrice}"/>
    </apex:dataTable>
</apex:component>
public class orderedLineItems {  
        public Id opportunityID {get; set;}
        List<OpportunityLineItem> lineItems;
        public List<OpportunityLineItem> getlineItems(){
            if(lineItems == null){
            lineItems = [select Id, PricebookEntry.Name, Quantity, UnitPrice, TotalPrice from OpportunityLineItem where OpportunityID =:opportunityID order by PricebookEntry.Name];
            }
            return lineItems;
        }
}
<c:orderedLineItems opportunityID="{!Opportunity.Id}"/>



List<Opportunity> opps = sortTest.getOpps();

    Integer before = Limits.getScriptStatements();
    sortTest.quicksortOpptys(opps,0,opps.size() - 1);
    Integer after = Limits.getScriptStatements();

    System.debug('SCRIPT STATEMENTS USED BY THE CUSTOM SORT: ' + (after - before));

    sortTest.doAsserts(opps);
}

               
/* Test the aproach of using the standard list.sort() method and a map */
public static testmethod void testStandardSort() {

    List<Opportunity> opps = sortTEST.getOpps();
    Integer before = Limits.getScriptStatements();
    opps = sortTest.sortStandard(opps);
    Integer after = Limits.getScriptStatements();
    System.debug('SCRIPT STATEMENTS USED BY THE STANDARD SORT: ' + (after - before));
    sortTest.doAsserts(opps);

}

    
/* Quicksort method as described on the boards adapted to use an opportunity collection. */
private static void quicksortOpptys(List<opportunity> a, Integer lo0, Integer hi0) {
    Integer lo = lo0;
    Integer hi = hi0;
    Opportunity pivot = a[(lo + hi) / 2];
    a[(lo + hi) / 2] = a[hi];
    a[hi] = pivot;
    while( lo < hi ) {
        while (a[lo].amount <= pivot.amount && lo < hi) { lo++; }
        while (pivot.amount <= a[hi].amount && lo < hi ) { hi--; }

        if( lo < hi ){
            Opportunity o = a[lo];
            a[lo] = a[hi];
            a[hi] = o;
        }
    }
            
    a[hi0] = a[hi];
    a[hi] = pivot;

    quicksortOpptys(a, lo0, lo-1);
    quicksortOpptys(a, hi+1, hi0);

}

/* Get a recent set of opportunities with non-null amounts for use in each test */
private static List<Opportunity> getOpps() {

/* If your org does not have sufficient data, you can create opportunities with 
    random amounts here instead of querying. */
return [select name, amount 
        from opportunity 
        where amount > 0 
        order by createddate desc 
        limit 25];
}

/* Assert the collection is ordered ascending. */
private static void doAsserts(List<Opportunity> opps) {

    Decimal assertValue = -1;
    for(Opportunity o:opps) {
            System.debug('OPPTY VALUE: ' + o.amount);
        System.assert(assertValue <= o.amount);
        assertValue = o.amount;
    }  
}

/*Email Service Limitation */
Max. Email : 1000*number of licenses or 10 lakhs.
Attachment size : 25MB
Text Body/Html Body  size : 100kb
Text Attachement/Binary Attachment Size : ("text/plain", "text/html")100kb/5Mb.(Mime type of "message/rfc822")

Size Of EmailMessage : 25mb. with 5MB single file attachment.


/*VisualForce Email Template */
<messaging:emailTemplate> : 
 recipientType also called the WhoID
 secondly the relatedToType also refered to as the whatID

<messaging:emailTemplate recipientType="Contact"
    relatedToType="Account"
    subject="Case report for Account: {!relatedTo.name}"
    replyTo="support@acme.com" >

//html content for email template
<messaging:htmlEmailBody >        
    <html>
        <body>
        <STYLE type="text/css">
            TH {font-size: 11px; font-face: arial;background: #CCCCCC; border-width: 1;  text-align: center } 
            TD  {font-size: 11px; font-face: verdana } 
            TABLE {border: solid #CCCCCC; border-width: 1}
            TR {border: solid #CCCCCC; border-width: 1}
        </STYLE>
        <font face="arial" size="2">
        <p>Dear {!recipient.name},</p>
        <p>Below is a list of cases related to the account: {!relatedTo.name}.</p>
        <table border="0" >
            <tr> 
                <th>Action</th><th>Case Number</th><th>Subject</th><th>Creator Email</th><th>Status</th>
            </tr>
            <apex:repeat var="cx" value="{!relatedTo.Cases}">
                <tr>
                    <td><a href="https://na1.salesforce.com/{!cx.id}">View</a> |  
                    <a href="https://na1.salesforce.com/{!cx.id}/e">Edit</a></td>
                    <td>{!cx.CaseNumber}</td>
                    <td>{!cx.Subject}</td>
                    <td>{!cx.Contact.email}</td>
                    <td>{!cx.Status}</td>
                </tr>
            </apex:repeat>                 
        </table>
        </body>
    </html>
</messaging:htmlEmailBody> 

<messaging:plainTextEmailBody >
    Dear {!recipient.name},
    Below is a list of cases related to Account: {!relatedTo.name}
    [ Case Number ] - [ Subject ] - [ Email ] - [ Status ]
    <apex:repeat var="cx" value="{!relatedTo.Cases}">
        [ {!cx.CaseNumber} ] - [ {!cx.Subject} ] - [ {!cx.Contact.email} ] - [ {!cx.Status} ]
    </apex:repeat>
</messaging:plainTextEmailBody>    

</messaging:emailTemplate>

/*Merge Idea Field In Email Template */
<messaging:emailTemplate subject="Communityforce New Idea '{!relatedTo.title} '" 
recipientType="User" 
relatedToType="Idea"
replyTo="YourEmailAddress">

<messaging:htmlEmailBody >
    <font face="verdana" size="2">
<p> This is an auto-notification. A new idea has been posted, {!relatedTo.title}. Catagorie(s): {!relatedTo.Categories}</p>
Full description:<p/>
{!relatedTo.Body}
<p/>
You can view the new idea <a href="https://xxx.salesforce.com/ideas/viewIdea.apexp?id={!relatedTo.id}">here</a> and vote for it.
</font>
</messaging:htmlEmailBody>

<!-- HTML above and plain text beleow -->

<messaging:plainTextEmailBody >
This is an auto-notification.
A new idea has been posted, {!relatedTo.title}. Full description:
{!relatedTo.Body}
You can view/vote for the idea at https://xxx.salesforce.com/ideas/viewIdea.apexp?id={!relatedTo.id}
    
</messaging:plainTextEmailBody>

</messaging:emailTemplate>


/*Identifying Record With Tagging */

setup> customize > Tags–>Tag Settings 
Enable Public Tags
Customize–>User Interface

select name FROM ApexClass WHERE name like '%google%'


/*
    Integarte with amazon S3
*/

https://developer.salesforce.com/page/Installing_Force_for_Amazon_Web_Services
https://developer.salesforce.com/page/Facebook_Toolkit
https://developer.salesforce.com/blogs/developer-relations/2009/02/integrating-with-the-forcecom-platform.html
https://developer.salesforce.com/page/Google_Data_Authentication#Authenticating_to_the_Google_Data_APIs_service

/*Retriving Dynamic Picklist*/

Schema.DescribeFieldResult fieldResult = OfficeLocation__c.Country__c.getDescribe();

public List<SelectOption> getAccountTypes(){
    Schema.DescribeFieldResult fieldResult = Account.Type.getDescribe();
    return getPickListValues(fieldResult);
}

16:35:35:021 USER_DEBUG [2]|DEBUG|Schema.DescribeFieldResult[getByteLength=120;getCalculatedFormula=null;getCompoundFieldName=null;getController=null;getDefaultValue=null;getDefaultValueFormula=null;getDigits=0;getFilteredLookupInfo=null;getInlineHelpText=null;getLabel=Account Type;getLength=40;getLocalName=Type;getMask=null;getMaskType=null;getName=Type;getPrecision=0;getReferenceTargetField=null;getRelationshipName=null;getRelationshipOrder=null;getScale=0;getSoapType=STRING;getSobjectField=Type;getType=PICKLIST;isAccessible=true;isAggregatable=true;isAiPredictionField=false;isAutoNumber=false;isCalculated=false;isCascadeDelete=false;isCaseSensitive=false;isCreateable=true;isCustom=false;isDefaultedOnCreate=false;isDependentPicklist=false;isDeprecatedAndHidden=false;isDisplayLocationInDecimal=false;isEncrypted=false;isExternalId=false;isFilterable=true;isFormulaTreatNullNumberAsZero=false;isGroupable=true;isHighScaleNumber=false;isHtmlFormatted=false;isIdLookup=false;isNameField=false;isNamePointing=false;isNillable=true;isPermissionable=true;isQueryByDistance=false;isRestrictedDelete=false;isSearchPrefilterable=false;isSortable=true;isUnique=false;isUpdateable=true;isWriteRequiresMasterRead=false;]

public List<SelectOption> getPickListValues(Schema.DescribeFieldResult fieldResult){
    if(string.valueOf(fieldResult.getType()) == 'PICKLIST'){
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None',''));
        for( Schema.PicklistEntry f : ple){
        options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    return null;
}

16:40:52:006 USER_DEBUG [10]|DEBUG|(System.SelectOption[value="None", label="", disabled="false"], System.SelectOption[value="Prospect", label="Prospect", disabled="false"], System.SelectOption[value="Customer - Direct", label="Customer - Direct", disabled="false"], System.SelectOption[value="Customer - Channel", label="Customer - Channel", disabled="false"], System.SelectOption[value="Channel Partner / Reseller", label="Channel Partner / Reseller", disabled="false"], System.SelectOption[value="Installation Partner", label="Installation Partner", disabled="false"], System.SelectOption[value="Technology Partner", label="Technology Partner", disabled="false"], System.SelectOption[value="Other", label="Other", disabled="false"])

By setting immediate to true, validation rules are skipped and the action associated with the button is executed immediately.
<apex:CommandLink action="{!cancelApplication}" value="Cancel" styleClass="btn" id="btnCancel" immediate="true">

//Accessing Session Id and API Server URL parameters 

//$Api.Session_ID
<apex:page setup="true" controller="ApiCC" showHeader="false">
    <apex:form >
        <apex:outputpanel id="counter">
            <apex:outputtext value="click here" />
            <apex:actionSupport event="onclick" action="{!doLogin}" rerender="refreshId">
                <apex:param name="sessionId" assignTo="{!apiSessionId}" value="{!$Api.Session_ID}" />
                <apex:param name="serverURL" assignTo="{!apiServerURL}" value="{!$Api.Partner_Server_URL_140}" /> 
            </apex:actionSupport> 
        </apex:outputpanel><br/>
    </apex:form> 
    <apex:outputPanel id="refreshId">
        <apex:outputText value="API Session Id: {!apiSessionId}"/><br/>
        <apex:outputText value="API Server URL: {!apiServerURL}"/>
    </apex:outputPanel>
</apex:page> 
public class ApiCC{
    public String apiSessionId {get;set;} 
    public String apiServerURL {get;set;} 
    public PageReference doLogin(){ 
        System.debug('apiSessionId: ' + apiSessionId); 
        System.debug('apiServerURL: ' + apiServerURL);
        return null; 
    }
}


1. Consume SOAP.
2.//Basic AUthentication for SOAP
mysample.MySamplePort webservice = new mysample.MySamplePort();
webservice.inputHttpHeaders_x = new Map<String, String>();
credential__c xxxSoapCredential = credential__c.getInstance('xxx');
string baseencodeUsernamePassword = EncodingUtil.base64Encode(xxxSoapCredential.username__c:xxxSoapCredential.password__c);
webservice.inputHttpHeaders_x.put('Authorization', 'Basic <span style="font-family: Courier;font-size: 11px">baseencodeUsernamePassword</span>');


//sobject cloing
clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber);

isDeepClone : true (refrernce)
              false (value copy)

/*ClassiC HOME PAGE */
https://help.salesforce.com/articleView?id=customize_homepage.htm&type=5


DateTime now = System.now();         
String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(formattednow));         
String token =  EncodingUtil.base64Encode(bsig);                 
if(token.length() > 255) { token =  token.substring(0,254); }        
i.Invite_Code__c = Encodingutil.urlEncode(token, 'UTF-8').replaceAll('%','_');


//Passing URL parameters into a Visualforce page from a custom button or link

Objects > SpecificObject > Button,link,Action > 
.New Button or Link
    .DetailPage Link/Button
    .Display as
    .URL

/page/apexpagename?param=value&param2=value2... ...


/*Round Robin Lead Assignment */

Formula Field :

LeadNumber__C,AutoNUmber,{0}{
MOD(VALUE({!Lead_Number__c}) ,3) +1
LeadAssignmentRule :
1. User1,Queue1.
2. User2,Queue2.
3. User3,Queue3.

//new feature can add visualforce page in detail page.

OrgWide Address :

Share common email address by all profile or specific profile as alias.
select id, Address,IsAllowAllProfiles from OrgWideEmailAddress

https://developer.salesforce.com/blogs/engineering/2009/08/more-secure-sites-webforms-with-encrypted-keys.html


/2009/09


//Simple Quote 

//Apex Sharing

ObjApiName/Share/_Share  shareRecord = new ObjApiName/Share/_Share ();
shareRecord.parentId = rec.id;
shareRecord.UserOrGroupId = ;
shareRecord.accessLevel = 'read,edit,all';
shareRecord.RowCause  = schema.objeApiNameShare/_Share.RowCause...;
insert shareRecord;

Mixed_DML_Exception

/*
TIMEZONE ISSUE :
*/

//display current user time
DateTime.now().format();

//as per user timezone system fields displays value.
cretaedDate,LastModifyDate Depends Upon Current User Time Zone Setup.
when devloper retrive record and access createdDate then display time will be added with addtional time
as per timezone.

Created an opportunity name TmeZoneChecker on timestamp on india 25th 10 2018 11 : @@ . When Record Created
dispalying time is 24/10/2018 10:56 PM as user timezone is LOSANGLES.

//Displaying after additional time additional Thu Oct 25 05:56:27 GMT 2018
string createdRecordTm =
[select createdDate FROM opportunity WHERE name='TmeZoneChecker' ORDER BY CreatedDate DESC Limit 1].createdDate;
//Converts the date to the local time zone
string displayOriginalTime = createdRecordTm.format();

now();//Display with respect to GMT


newInsatnce();//local Time zone
newInsatnceGMT();//GMT Time Zone

format();//local Time Zone
formatGMT();//GMT Time Zone


//convert it to specific timeZone
.Convert to GMT.
.
public static Integer getOffSetTime(){
    //get current User TimeZone
    TimeZone tz = UserInfo.getTimeZone();
    //from tz get oggset time in ms
    Integer offsetTm = tz.getOffset(System.now()) ;
    System.debug('Offset Time In MiliSeconds : '+offsetTm);
    Integer offsetHr = (offsetTm/3600)==0?offsetTm:(offsetTm/3600);
    Integer offsetMin = (offsetTm%3600)>60?((offsetTm%3600)/60 == 0?(offsetTm%3600):(offsetTm%3600)/60):(offsetTm%3600);
    Integer offsetSec = offsetTm - ((offsetTm*3600) + (offsetMin*60));
    System.debug('Offset Time In Hr : '+offsetHr+'Min : '+offsetMin+'Sec : '+offsetSec);
}

//String to DateTime Conversion with any change in time
System.TypeException : Invalid date/time
DateTime recentOppCreatedTm = [select createdDate FROM opportunity ORDER BY CreatedDate DESC Limit 1].createdDate;
DateTime dt1 = Datetime.valueOf(recentOppCreatedTm.format('yyyy-MM-dd HH:mm:ss'));
DateTime dt2 = Datetime.newInstance(recentOppCreatedTm.year(), recentOppCreatedTm.month(),recentOppCreatedTm.day(),recentOppCreatedTm.hour(),recentOppCreatedTm.minute(),recentOppCreatedTm.second());

//String to DateTime Conversion with respect to GMT (Offest value added)
DateTime dt2GMT = Datetime.newInstance(recentOppCreatedTm.year(), recentOppCreatedTm.month(),recentOppCreatedTm.day(),recentOppCreatedTm.hour(),recentOppCreatedTm.minute(),recentOppCreatedTm.second());

FIELD_INTEGRITY_EXCEPTION : DateTime.valueOfGmt(('06/08/2013 06:30:22').replaceAll('/','-'));


TimeZone tz = UserInfo.getTimeZone();
Integer offsetToCustomersTimeZone = customerTimeZone.getOffset(customerDateTime);
Integer offsetTimeInSeconds = (offsetToCustomersTimeZone/1000) == 0 ? offsetToCustomersTimeZone : offsetToCustomersTimeZone/1000;


trigger SetTaskType on Task (before insert) {
    For (Task tsk : Trigger.new) {
        String subject = tsk.Subject;
        String description = tsk.Description;
   
        if ( subject != null && subject.startsWith('Email:') && description.startsWith('Additional To:')) {
            tsk.Type = 'Email';
        }
    }
}

//Passing Javascript values to Apex Controller

<apex:outputPanel>
    <apex:outputText value="passparam" />
    <apex:actionSupport event="onclick">
        <apex:param name="sessionId" assignTo="{!apiSessionId}" value="{!$Api.Session_ID}" />
    </apex:actionSupport>
</apex:outputPanel>

public string apiSessionId{get;set;}

<apex:page controller="ActionPageController">
    <apex:form >
        <apex:actionFunction name="hitMe" action="{!iWantMyJSValues}" rerender="jsvalues">
            <apex:param name="one" value="" />
            <apex:param name="two" value="" />
        </apex:actionFunction>
        <apex:outputPanel id="jsvalues">
            <apex:outputText value="Value one: {!valueOne}" /><br/>
            <apex:outputText value="Value two: {!valueTwo}" /><br />            
        </apex:outputPanel>
        <span style="cursor: pointer;" onclick="hitMe(Date(), 'best shot')">Hit Me</span>
    </apex:form>
</apex:page>

or
<script>
    function jsCall(){
        hitMe(Date(),'best shot');
    }
</script>
<apex:commandButton name="click" onclick="jsCall()"/>

public with sharing class ActionPageController {

    public String valueOne { get; set; }
    public String valueTwo { get; set; }
    
    public PageReference iWantMyJSValues() {
        valueOne = Apexpages.currentPage().getParameters().get('one');
        valueTwo = Apexpages.currentPage().getParameters().get('two');
        return null;
    }
}

//Remote Site Setting  =  END POINT URL

Creating Record In User Trigger

trigger UserTrigger on User(after insert){
    UserTriggerHandler.insertTask();
}

public class UserTriggerHandler{
    @Futrue
    public static void insertTask(List<Id> userIds){
        List<Sobject>  slsts = new List<Sobject>();
        for(Id userId : userIDs){

        }
        if(!slsts.isEmpty()){
            insert slsts;
        }
    }
}

//paypal tollkit


//picture uploader
<!--showPicture-->
<apex:page id="uploadImagePage" standardController="Contact" extensions="Contactsextension">
</apex:page>

<!--showPictureCustom-->
<apex:page id="showImagePage" standardController="Contact" extensions="ShowPicture">
</apex:page>

Objects > Button,Link.. > New Button > Upload Picture

var Id = '{!My_Custom_Object__c.Id}';
location.href = '/apex/fileuploadCustom?id='+Id;


//loading larger ste up data workbench  blulk api


//https://developer.salesforce.com/developer-centers/integration-apis



//secure coding guideline

//XSS vunerability
<apex:outputText>/<div>
    <!-- safe (auto HTML Encoded) -->
    {!$Currentpage.parameters.paramname}
</apex:outputText>/</div>

<script>
  var x = '{!JSENCODE($CurrentPage.parameters.userInput)}'; //safe
  //place value inside JSENCODE(value)
</script>
//url safety
var x = '{!URLENCODE(Pic.name)}';

//SOQL Injection

String qtitle = '%' + userInputTitle + '%';
String whereClause += ''+'Title__c like  \'%'+userInputTitle+'%\’’;
List<sobject> whereclause_records = database.query(query+' where '+whereClause);

//make it static 
String qtitle = '%' + userInputTitle + '%';
List<sobject> whereclause_records = [SELECT Name, Role__c, Title__c, Age__c from Personnel__c  WHERE Title__c like :qTitle];
;
String query = 'select Name, Title from myObject__c where Name like \'%'+String.escapeSingleQuotes(name)+'%\'';
List<sobject> whereclause_records = Database.query(query);

//Cross Site Request Forgery

List<Account> accLst = [select id FROM Account WHERE ID=:Apexpages.currentpage().getParameters().get('id')];


trigger on 
FeedItem    : entry in the feed, such as changes in a record feed, including text posts, link posts, and                    content posts.
FeedComment : Represents a comment added to a feed by a user.


