public class AUPJSONGenerator{
    
    public String generateJSONContent(String eventType,SObject eventMessage) {
        // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);
        String pretty = '';
        
        
        system.debug('3001000---$$$$$$$$$-AUPJSONGenerator:generateJSONContent:passed in message: '+eventMessage);
        // Write data to the JSON string.
        try {
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
            pretty = gen.getAsString();
            system.debug('300120---$$$$$$$$$-generateJSONContent:Message preparing to send: '+pretty);
        }catch(system.CalloutException e){            
            system.debug('3001100---$$$$$$$$$-AUPJSONGenerator:error:generateJSONContent: '+e);
        }
        
        return pretty;
    }
}