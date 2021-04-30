public class ADPublishUserEvent {
    
    public ADPublishUserEvent(){
    }
    
    public String execute(String passedJSon){
        
        //String endpoint='https://enterprise-momentum-4091-dev-ed.cs10.my.salesforce.com/services/oauth2/token';
        
        String username = 'test-rnyylfrlgcbo@example.com'; 
        String password = 'Stay@ut!2021058OZMCc9ZdJZqen6HjvXWkbrz';
        String ClientId= '3MVG9CxwbdV68qJKXzSb.DcY3C2.5z1phRYoiGJWXywaNXKsyZSXUKrd2lvxnG0FWK.wJ6di7lXCg60QXxfLe';
        String ClientSecret = 'B681FBC677FB48BEA31F3EA35791BCD6C67B52A6FF2B6A53124D835AF7AFA114';
        
        //String authEndPoint = 'https://data-velocity-8782-dev-ed.lightning.force.com/services/oauth2/token';
        String authEndPoint = 'https://data-velocity-8782-dev-ed.lightning.force.com';
        // 					   https://data-velocity-8782-dev-ed.cs97.my.salesforce.com/
        String postEndPoint = 'https://data-velocity-8782-dev-ed.lightning.force.com/services/apexrest/v1/adupdateuserservice/postADUserEvent';
        
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
        req1.setBody(sJSonStr.generateJSONContent()); 
        
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
        /*
Group_Name__c=grp.AD_Group_Name__c,
Email_Address__c=adUser.AD_User_Email__c,
Federation_Id__c=adUser.AD_Federation_Id__c,
FirstName__c=adUser.AD_First_Name__c,
LastName__c=adUser.AD_Last_Name__c,
Parent_AD_Group__c=parentGroupName,
Status__c=grp.Status__c));                    
*/
        
        private String generateJSONContent() {
            // Create a JSONGenerator object.
            // Pass true to the constructor for pretty print formatting.
            JSONGenerator gen = JSON.createGenerator(true);
            
            // Create a list of integers to write to the JSON string.
            List<integer> intlist = new List<integer>();
            intlist.add(1);
            intlist.add(2);
            intlist.add(3);
            
            // Create an object to write to the JSON string.
            //A x = new A('X');
            
            // Write data to the JSON string.
            gen.writeStartObject();
            gen.writeStringField('GroupName', 'OHRS-Supervisor');
            gen.writeStringField('EmailAddress', 'wsteele@salesforce.com');
            gen.writeStringField('FederationId', 'wsteele@salesforce.com');
            gen.writeStringField('FirstName', 'William');
            gen.writeStringField('LastName', 'Steele');
            gen.writeStringField('ParentADGroup', 'Salesforce');
            gen.writeStringField('Status', 'Active');
            /*
gen.writeNumberField('abc', 1.21);
gen.writeStringField('def', 'xyz');
gen.writeFieldName('ghi');
gen.writeStartObject();

gen.writeObjectField('aaa', intlist);

gen.writeEndObject();

gen.writeFieldName('Object A');

gen.writeObject(x);
*/
            gen.writeEndObject();
            
            // Get the JSON string.
            String pretty = gen.getAsString();
            System.debug('generateJSONContent:Message preparing to send: '+pretty);
            
            /*()
System.assertEquals('{\n' +
'  "abc" : 1.21,\n' +
'  "def" : "xyz",\n' +
'  "ghi" : {\n' +
'    "aaa" : [ 1, 2, 3 ]\n' +
'  },\n' +
'  "Object A" : {\n' +
'    "str" : "X"\n' +
'  }\n' +
'}', pretty);
*/
            return pretty;
        }
    }
    
    
}