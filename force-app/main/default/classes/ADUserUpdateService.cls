@RestResource(urlMapping='/v1/adupdateuserservice/*')
global with sharing class ADUserUpdateService {
    
    public class UserEventType {
        public String GroupName;
        public String EmailAddress;
        public String FederationId;
        public String FirstName;
        public String LastName;
        public String ParentADGroup;
        public String Status;
	}
    
    public String GroupName;
    public String EmailAddress;
    public String FederationId;
    public String FirstName;
    public String LastName;
    public String ParentADGroup;
    public String Status;
    
	//public String packageName;

    //public List<PackageTypes> packageTypes;

	
	public static ADUserUpdateService parse(String json) {
		return (ADUserUpdateService) System.JSON.deserialize(json, ADUserUpdateService.class);
	}

    
    @HttpPost
    global static String postADUserEvent() 
    {
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

		String returnMessase = 'Success';
        String requestBody = req.requestBody.toString();
        requestBody = requestBody;
        
        try {
            ADUserUpdateService adUserPlatformEvent = ADUserUpdateService.parse(req.requestBody.toString());
            
            System.debug('ADUserUpdateService:postADUserEvent:adUserPlatformEvent: '+adUserPlatformEvent);
            //Email Address	50
            //Federation Id	50
            //FirstName		80
            //LastName		80
            //Group Name		80
            //Parent AD Group	80
            //Status			50
            //[46]|DEBUG|ADUserUpdateService:postADUserEvent:adUserPlatformEvent: ADUserUpdateService:[
            //EmailAddress=wsteele@salesforce.com, 
            //FederationId=wsteele@salesforce.com, 
            //FirstName=William, 
            //GroupName=OHRS-Supervisor, 
            //LastName=Steele, 
            //ParentADGroup=Salesforce, 
            //Status=Active]
            AD_Group_Update__e groupEvent = new AD_Group_Update__e( 
                Group_Name__c=adUserPlatformEvent.GroupName,
                Email_Address__c=adUserPlatformEvent.EmailAddress,
                Federation_Id__c=adUserPlatformEvent.FederationId,
                FirstName__c=adUserPlatformEvent.FirstName,
                LastName__c=adUserPlatformEvent.LastName,
                Parent_AD_Group__c=adUserPlatformEvent.ParentADGroup,
                Status__c=adUserPlatformEvent.Status);                    
    
            
            // Call method to publish events
            Database.SaveResult srs = EventBus.publish(groupEvent);
            // Inspect publishing result
                if (srs.isSuccess()) {
                    System.debug('ADUserUpdateService:postADUserEvent:processTransactions:Successfully published event: '+srs);
                } else {
                    for(Database.Error err : srs.getErrors()) {
                        System.debug('Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }
            System.debug('ADUserUpdateService:postADUserEvent:processTransactions:FINISHING UP!');
            
        } catch (Exception dme) {
			returnMessase = 'Failure: '+dme.getMessage();
        }
        return returnMessase;
    }
}