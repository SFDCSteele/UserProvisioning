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
     */
    public String execute(String eventType, SObject eventMessage){
        
        String returnString = '';
        
        AUP_Core_Functionality_Settings__c aupSettings = AUP_Core_Functionality_Settings__c.getInstance();
        
        if ( aupSettings.AUP_ENT_Execute__c ) {
            returnString = sendUserEvent (eventType, aupSettings, eventMessage);
        }
        
        return returnString;
    }
    
    private String sendUserEvent (String eventType, AUP_Core_Functionality_Settings__c aupSettings, SObject eventMessage) {
        
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
        System.debug('ADPublishUserEvent:execute: '+loginURL);
		
        //req.setBody('grant_type=password&client_id=' + ClientId + '&client_secret=' + ClientSecret + '&username=' + username +'&password=' + password); 
        
        req.setEndpoint(loginURL);
        //req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        Http http = new Http();
        HttpResponse res;       
        String Access_Token;
        try {
            res = http.send(req);
            system.debug('FIRST: body:'+res.getBody()+' status: '+res.getStatus()+' status code: '+res.getStatusCode()+' location: '+res.getHeader('Location'));  
            while (res.getStatusCode() == 302) {
                req.setEndpoint(res.getHeader('Location'));
                res = new Http().send(req);
			}
            system.debug('SECOND: body:'+res.getBody()+' status: '+res.getStatus()+' status code: '+res.getStatusCode()+' location: '+res.getHeader('Location'));  
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    Access_Token = parser.getText();    
                } 
            }            
        }catch(system.CalloutException e){            
            system.debug('error'+e);
        }
        
        system.debug('access token: '+Access_Token);
        Httprequest req1 = new HttpRequest();  
        req1.setEndpoint(postEndPoint);  
        req1.setMethod('POST');    
        //req1.setHeader('Content-Type','application/x-www-form-urlencoded');
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('Authorization','Bearer '+Access_Token);  
        //req1.setBody(passedJSon); 
        AUPJSONGenerator sJSonStr = new AUPJSONGenerator();
        String aupJSONString = sJSonStr.generateJSONContent(eventType, eventMessage);
        req1.setBody(aupJSONString); 
        
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);                 
        system.debug('ALMOST LAST: body:'+res1.getBody()+' status: '+res1.getStatus()+' status code: '+res1.getStatusCode()+' location: '+res1.getHeader('Location'));  
        while (res1.getStatusCode() == 302) {
            req1.setEndpoint(res1.getHeader('Location'));
            res1 = new Http().send(req1);
        }
        system.debug('LAST: body:'+res1.getBody()+' status: '+res1.getStatus()+' status code: '+res1.getStatusCode()+' location: '+res1.getHeader('Location'));  
        return res1.getBody();
    }
    
    public class AUPJSONGenerator{
               
        private String generateJSONContent(String eventType,SObject eventMessage) {
            // Create a JSONGenerator object.
            // Pass true to the constructor for pretty print formatting.
            JSONGenerator gen = JSON.createGenerator(true);
            
            
            // Write data to the JSON string.
            gen.writeStartObject();
            if (eventType.equals('User')) {
	            gen.writeStringField('SECID', (String)eventMessage.get('AD_SEC_ID__c'));
	            gen.writeStringField('FederationId', (String)eventMessage.get('AD_Federation_Id__c'));
	            gen.writeStringField('Status', (String)eventMessage.get('Status__c'));
            } else {
                gen.writeStringField('GroupName', (String)eventMessage.get('Group_Name__c'));
                gen.writeStringField('EmailAddress', (String)eventMessage.get('Email_Address__c'));
                gen.writeStringField('FederationId', (String)eventMessage.get('Federation_Id__c'));
                gen.writeStringField('SECID', (String)eventMessage.get('AD_SEC_ID__c'));
                gen.writeStringField('FirstName', (String)eventMessage.get('FirstName__c'));
                gen.writeStringField('LastName', (String)eventMessage.get('LastName__c'));
                gen.writeStringField('ParentADGroup', (String)eventMessage.get('Parent_AD_Group__c'));
                gen.writeStringField('Status', (String)eventMessage.get('Status__c'));
            }
            gen.writeEndObject();
            
            // Get the JSON string.
            String pretty = gen.getAsString();
            System.debug('generateJSONContent:Message preparing to send: '+pretty);
            
            return pretty;
        }
    }
    
    
}