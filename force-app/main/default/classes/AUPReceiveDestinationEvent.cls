@RestResource(urlMapping='/AUPDestinationUserService/*')
global without sharing class AUPReceiveDestinationEvent {    

    @HttpPost
    global static String postAUPUserEvent() 
    {
        System.debug('postAUPUserEvent: inside POST...');
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
	    String returnMessage = '';
        List<AUP_Destination_User_Event__e> userEvents = new List<AUP_Destination_User_Event__e>();
        AUP_Destination_User_Event__e userEvent = new AUP_Destination_User_Event__e();

        try {
            System.debug('101-Body: ' + (req.requestBody != null ? req.requestBody.toString() : ''));
            System.debug('Params: ' + req.params);
            System.debug('requestBody: '+req.requestBody.toString() );
            System.debug('JsonDeserialize: '+JSON.deserializeUnTyped(req.requestBody.toString()) );
        }
        catch (Exception e) {
            res.statusCode = 500;
            return e.getStackTraceString();
        }
        
        try {
            AUPDestinationUserService.execute(JSONToUserEvents(req.requestBody.toString()));
                        
        }
        catch (Exception e) {
            res.statusCode = 500;
            System.debug('Exception: '+e.getStackTraceString());
            return e.getStackTraceString();
        }
        return returnMessage;
    }
    
    private static List<AUP_Destination_User_Event__e> JSONToUserEvents (String inComingJSON ) {
        List<AUP_Destination_User_Event__e> incomingMessages = new List<AUP_Destination_User_Event__e>();
        
        AUPDestinationEvent destEvent = AUPDestinationEvent.parse(inComingJSON);
        incomingMessages.add(new AUP_Destination_User_Event__e(AD_SEC_ID__c=destEvent.AD_SEC_ID, 
                                                Email_Address__c=destEvent.Email_Address, 
                                                Federation_Id__c=destEvent.Federation_Id, 
                                                FirstName__c=destEvent.FirstName, 
                                                LastName__c=destEvent.LastName, 
                                                Profile_Name__c=destEvent.Profile_Name, 
                                                Role_Name__c=destEvent.Role_Name, 
                                                License_Name__c=destEvent.License_Name, 
                                                Username__c=destEvent.Username, 
                                                Alias__c=destEvent.Alias, 
                                                Permission_Set_Groups__c=destEvent.Permission_Set_Groups, 
                                                Permission_Sets__c=destEvent.Permission_Sets, 
                                                Destination_Org__c=destEvent.Destination_Org, 
                                                Groups__c=destEvent.Groups, 
                                                Queues__c=destEvent.Queues, 
                                                Status__c=destEvent.Status,
                                                Permission_Set_Licenses__c=destEvent.Permission_Set_Licenses));
        
        return incomingMessages;
    }
    
}