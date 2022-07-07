public class ADPublishUserEvent {
    
    public ADPublishUserEvent(){
    }
    /*
     * 
     * how to run this
     *         
            ADPublishUserEvent evntPub = new ADPublishUserEvent();
            evntPub.execute('User',new AD_User_Inactivation__e(AD_SEC_ID__c='10101010',AD_Federation_Id__c='mickey@mouse_fed.com', Status__c='Inactive'));

            ADPublishGroupEvent evntPub = new ADPublishGroupEvent();
			evntPub.execute('Group',new AD_Group_Update__e(
                                    AD_SEC_ID__c='10101010',
                                    Group_Name__c=grp.AD_Group_Name__c,
                                    Email_Address__c='mickey@mouse_email.com',
                                    Federation_Id__c='mickey@mouse_fed.com',
                                    FirstName__c=adUser.AD_First_Name__c,
                                    LastName__c=adUser.AD_Last_Name__c,
                                    Parent_AD_Group__c=parentGroupName,
                                    Status__c=grp.'Active'));  
     * 
    
    @future(callout=true)
    public static void processUserEvents (List<Id> IdsToProcess) {
        
        List<Profile> prof = [Select Id,Name from Profile where Name='System Administrator'];
        AUP_Core_Functionality_Settings__c aupSettings = AUP_Core_Functionality_Settings__c.getInstance(prof[0].Id);
        String returnString = '';
        System.debug('200010.01-##############ADPublishUserEvent:processEvents:AUP Settings: '+
                     '\nExecute\t:\t'+aupSettings.AUP_ENT_Execute__c+
                     '\nUsername\t:\t'+aupSettings.AUP_ENT_Username__c+
                     '\npassword\t:\t'+aupSettings.AUP_ENT_Password__c+
                     '\nClientId\t:\t'+aupSettings.AUP_ENT_Client_Id__c+
                     '\nClientSecret\t:\t'+aupSettings.AUP_ENT_Client_Secret__c+
                     '\nentEndPoint\t:\t'+aupSettings.AUP_ENT_End_Point__c);
        
        System.debug('200020.01-##############ADPublishUserEvent:processEvents:Sending through the web service? '+aupSettings.AUP_ENT_Execute__c);
        if ( aupSettings.AUP_ENT_Execute__c ) {
	        List<AD_User__c> ADUsers = [SELECT Id, SECID__c, Name, AD_First_Name__c, AD_Last_Name__c, AD_User_Email__c, 
    	                                AD_Federation_Id__c, Status__c FROM AD_User__c WHERE Id =: IdsToProcess];
            ADPublishUserEvent evntPub = new ADPublishUserEvent();
	        System.debug('200030.01-##############ADPublishUserEvent:processEvents:users to process: '+ADUsers);
            
            execute('User',ADUsers,aupSettings);
        }
        
    }
     */
    
    @future(callout=true)
    public static void processEvents (String eventType, String msgSJONString) {
        
        System.debug('200000.01-##############ADPublishUserEvent:processEvents:inside method: eventType: '+eventType+' json: '+msgSJONString);
        List<Profile> prof = [Select Id,Name from Profile where Name='System Administrator'];
        AUP_Core_Functionality_Settings__c aupSettings = AUP_Core_Functionality_Settings__c.getInstance(prof[0].Id);
        String returnString = '';
        System.debug('200010.01-##############ADPublishUserEvent:processEvents:AUP Settings: '+
                     '\nExecute\t:\t'+aupSettings.AUP_ENT_Execute__c+
                     '\nUsername\t:\t'+aupSettings.AUP_ENT_Username__c+
                     '\npassword\t:\t'+aupSettings.AUP_ENT_Password__c+
                     '\nClientId\t:\t'+aupSettings.AUP_ENT_Client_Id__c+
                     '\nClientSecret\t:\t'+aupSettings.AUP_ENT_Client_Secret__c+
                     '\nentEndPoint\t:\t'+aupSettings.AUP_ENT_End_Point__c);
        
        System.debug('200020.01-##############ADPublishUserEvent:processEvents:Sending through the web service? '+aupSettings.AUP_ENT_Execute__c);
        if ( aupSettings.AUP_ENT_Execute__c ) {
            /*
	        List<AD_User__c> ADUsers = [SELECT Id, SECID__c, Name, AD_First_Name__c, AD_Last_Name__c, AD_User_Email__c, 
    	                                AD_Federation_Id__c, Status__c FROM AD_User__c WHERE Id =: IdsToProcess];
            ADPublishUserEvent evntPub = new ADPublishUserEvent();
			*/

	        System.debug('200030.01-##############ADPublishUserEvent:processEvents:events to process: '+msgSJONString);
            
            execute(eventType,msgSJONString,aupSettings);
        }
        
    }

    public Static String execute(String eventType, String msgSJONString, AUP_Core_Functionality_Settings__c aupSettings){
                
        String username = aupSettings.AUP_ENT_Username__c;
        String password = aupSettings.AUP_ENT_Password__c;
        String ClientId= aupSettings.AUP_ENT_Client_Id__c;
        String ClientSecret = aupSettings.AUP_ENT_Client_Secret__c;
        
        String entEndPoint  = aupSettings.AUP_ENT_End_Point__c;
        String authEndPoint = entEndPoint;
        String postEndPoint = '';
        if (eventType.equals('User')) {
            postEndPoint = entEndPoint + '/services/apexrest/ADUpdateUserService/postADUserEvent';
        } else {
            postEndPoint = entEndPoint + '/services/apexrest/ADUpdateGroupService/postADGroupEvent';
        }
        
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