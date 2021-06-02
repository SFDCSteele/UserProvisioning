@RestResource(urlMapping='/ADUpdateGroupService/*')
global without sharing class ADGroupReceiveEvent {    

    @HttpPost
    global static String postADGroupEvent() 
    {
        System.debug('ADGroupReceiveEvent: inside POST...');
		RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
	    String returnMessage = '';

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
            returnMessage = ADUpdateGroupService.execute(req.requestBody.toString());
                        
        }
        catch (Exception e) {
            res.statusCode = 500;
            System.debug('Exception: '+e.getStackTraceString());
            return e.getStackTraceString();
        }
        return returnMessage;
    }
    
}