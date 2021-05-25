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
            returnMessage = '';//ADUpdateUserService.execute(req.requestBody.toString());
                        
        }
        catch (Exception e) {
            res.statusCode = 500;
            System.debug('Exception: '+e.getStackTraceString());
            return e.getStackTraceString();
        }
        return returnMessage;
    }
    
}