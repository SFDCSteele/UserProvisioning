@RestResource(urlMapping='/ADUpdateUserService/*')
global without sharing class ADUserReceiveEvent {


	public String SECID {get;set;} 
	public String FederationId {get;set;} 
	public String Status {get;set;} 

    @HttpPost
    global static String postADUserEvent() 
    {
        System.debug('ADUserReceiveEvent: inside POST...');
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

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
            ADUpdateUserService r = ADUpdateUserService.parse(req.requestBody.toString());
            
            System.debug('ADUserReceiveEvent:SECID: '+r.SECID);
            System.debug('ADUserReceiveEvent:FederationId: '+r.FederationId);
            System.debug('ADUserReceiveEvent:Status: '+r.Status);
            
            if ( r.Status.equals('Inactive')) {
	            inactivateUser(r.SECID);
            }
            
        }
        catch (Exception e) {
            res.statusCode = 500;
            System.debug('Exception: '+e.getStackTraceString());
            return e.getStackTraceString();
        }
        return 'Success';
    }
    
    private static void inactivateUser (String SECID) {
        
        System.debug('ADUserReceiveEvent:looking for SECID: '+SECID);
		List<User> inActivateUsers = new List<User>();
        for (User usr : [select Id, username, SECID__C,IsActive from User where SECID__c =: SECID]) {
            usr.IsActive = false;
            inActivateUsers.add(usr);
        }
        System.debug('ADUserReceiveEvent:preparing to update users: '+inActivateUsers);
        
        try {
	        update inActivateUsers;
        } catch (Exception e) {
            System.debug('ADUserReceiveEvent:inactivateUser:Exception: '+e.getStackTraceString());
            //return e.getStackTraceString();
        }
    }
}