public class AUPPublishDestinationEvent {
    
    public AUPPublishDestinationEvent(){
    }
    
    @future(callout=true)
    public static void processEvents (String eventType, String msgSJONString) {
        
        List<Profile> prof = [Select Id,Name from Profile where Name='System Administrator'];
        Destination_Org__c destOrg = [select Id, Dest_Client_Id__c,Dest_Client_Secret__c,Dest_Password__c,Dest_Username__c,Destination_End_Point__c,Destination_Org__c 
                                      FROM Destination_Org__c  where Destination_Org__c =: eventType limit 1];
        String returnString = '';
        System.debug('200010.01-##############AUPPublishDestinationEvent:processEvents:destOrgs: '+
                     '\nDestination Org\t:\t'+destOrg.Destination_Org__c+
                     '\nUsername\t:\t'+destOrg.Dest_Username__c+
                     '\npassword\t:\t'+destOrg.Dest_Password__c+
                     '\nClientId\t:\t'+destOrg.Dest_Client_Id__c+
                     '\nClientSecret\t:\t'+destOrg.Dest_Client_Secret__c+
                     '\nentEndPoint\t:\t'+destOrg.Destination_End_Point__c);
        
        System.debug('200020.01-##############AUPPublishDestinationEvent:processEvents:Sending through the web service? '+destOrg.Destination_Org__c);
        if ( destOrg != null ) {

	        System.debug('200030.01-##############AUPPublishDestinationEvent:processEvents:events to process: '+msgSJONString);
            
            execute(eventType,msgSJONString,destOrg);
        }
        
    }

    public Static String execute(String eventType, String msgSJONString, Destination_Org__c destOrg){
                
        String username = destOrg.Dest_Username__c;
        String password = destOrg.Dest_Password__c;
        String ClientId= destOrg.Dest_Client_Id__c;
        String ClientSecret = destOrg.Dest_Client_Secret__c;
        
        String entEndPoint  = destOrg.Destination_End_Point__c;
        String authEndPoint = entEndPoint;
        String postEndPoint = entEndPoint + '/services/apexrest/AUPDestinationUserService/postAUPUserEvent';
        
        Httprequest req = new HttpRequest();    
        req.setMethod('POST');    
        //req.setHeader('Content-Type','application/json');
        
        //req.setBody('grant_type=password + &client_id=' + ClientId + '&client_secret=' + ClientSecret + '&username=' + username +'&password=' + password); 
        //export CICD_GRANTSERVICE=/services/oauth2/token?grant_type=password
        //        
        // Assemble the login request URL
        String loginURL = authEndPoint +
                          '/services/oauth2/token?grant_type=password' +
                          '&client_id=' + ClientId +
                          '&client_secret=' + ClientSecret +
                          '&username=' + username +
                          '&password=' + password;
        system.debug('300010---$$$$$$$$$-ADPublishUserEvent:execute: '+loginURL);
		
        //req.setBody('grant_type=password&client_id=' + ClientId + '&client_secret=' + ClientSecret + '&username=' + username +'&password=' + password); 
        
        req.setEndpoint(loginURL);
        //req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        Http http = new Http();
        HttpResponse res;       
        String Access_Token;
        try {
            res = http.send(req);
            system.debug('300020---$$$$$$$$$-FIRST: body:'+res.getBody()+' status: '+res.getStatus()+' status code: '+res.getStatusCode()+' location: '+res.getHeader('Location'));  
            while (res.getStatusCode() == 302) {
                req.setEndpoint(res.getHeader('Location'));
                res = new Http().send(req);
			}
            system.debug('300030---$$$$$$$$$-SECOND: body:'+res.getBody()+' status: '+res.getStatus()+' status code: '+res.getStatusCode()+' location: '+res.getHeader('Location'));  
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    Access_Token = parser.getText();    
                } 
            }            
        }catch(system.CalloutException e){            
            system.debug('300040---$$$$$$$$$-error:   '+e);
        }
        
        system.debug('300050---$$$$$$$$$-access token: '+Access_Token);
        Httprequest req1 = new HttpRequest();  
        req1.setEndpoint(postEndPoint);  
        req1.setMethod('POST');    
        //req1.setHeader('Content-Type','application/x-www-form-urlencoded');
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('Authorization','Bearer '+Access_Token);  
        //req1.setBody(passedJSon); 
        //AUPJSONGenerator sJSonStr = new AUPJSONGenerator();
        //String aupJSONString = '';
        system.debug('300060---$$$$$$$$$-event messages: '+msgSJONString);  
        /*
        for (SObject evntMsg : eventMessages ) {
        	aupJSONString += sJSonStr.generateJSONContent(eventType, evntMsg);            
        }
		*/
        req1.setBody(msgSJONString); 
        
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);                 
        system.debug('300070---$$$$$$$$$-ALMOST LAST: body:'+res1.getBody()+' status: '+res1.getStatus()+' status code: '+res1.getStatusCode()+' location: '+res1.getHeader('Location'));  
        while (res1.getStatusCode() == 302) {
            req1.setEndpoint(res1.getHeader('Location'));
            res1 = new Http().send(req1);
        }
        system.debug('300080---$$$$$$$$$-LAST: body:'+res1.getBody()+' status: '+res1.getStatus()+' status code: '+res1.getStatusCode()+' location: '+res1.getHeader('Location'));  
        return res1.getBody();
    }
        
}