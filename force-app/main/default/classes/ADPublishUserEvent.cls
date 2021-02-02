public class ADPublishUserEvent {
    
    public String ADPublishUserEvent(){
        
        //String endpoint='https://enterprise-momentum-4091-dev-ed.cs10.my.salesforce.com/services/oauth2/token';
        
        String username = 'test-fudubkdhqeya@example.com'; 
        String password = 'Stay@ut!202102';
        String ClientId= '3MVG9_7ddP9KqTzdd8NcBbiXojajSlyVZoZwww.gnMt725ndVV77wngBPt.MdxwojZablAntxYL9vf2HhGzmM';
        String ClientSecret = '71B67193960648AFBF40B04EAB3DBB0C4E3F9140083ED610330A82D3453DB4ED';
        
        String authEndPoint = 'https://enterprise-momentum-4091-dev-ed.cs10.my.salesforce.com/services/oauth2/token';
        String postEndPoint = 'https://enterprise-momentum-4091-dev-ed.cs10.my.salesforce.com/services/apexrest/v1/adupdateuserservice/postADUserEvent';
        
        Httprequest req = new HttpRequest();    
        req.setMethod('POST');    
        //req.setHeader('Content-Type','application/json');
        
        //req.setBody('grant_type=password + &client_id=' + ClientId + '&client_secret=' + ClientSecret + '&username=' + username +'&password=' + password); 
        req.setBody('grant_type=password&client_id=' + ClientId + '&client_secret=' + ClientSecret + '&username=' + username +'&password=' + password); 
        
        req.setEndpoint(authEndPoint);
        //req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        Http http = new Http();
        HttpResponse res;       
        String Access_Token;
        try {
            res = http.send(req);                
            system.debug('body:'+res.getBody());  
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
        system.debug('access token'+Access_Token);
        Httprequest req1 = new HttpRequest();  
        req1.setEndpoint(postEndPoint);  
        req1.setMethod('POST');    
        req1.setHeader('Content-Type','application/x-www-form-urlencoded');
        req1.setHeader('Authorization','Bearer '+Access_Token);            
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);                 
        system.debug('body11:'+res1.getBody()); 
        return res1.getBody();
    }
                         
                         
}