public class AUPJSONGenerator{
    
    public String generateJSONContent(String eventType,SObject eventMessage) {
        // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);
        String pretty = '';
        String wStr   = '';
        List<String> destNames = new List<String>{'AD_SEC_ID__c','Email_Address__c','Federation_Id__c','FirstName__c','LastName__c','Profile_Name__c','Role_Name__c',
            'License_Name__c','Username__c','Alias__c','Permission_Set_Groups__c','Permission_Sets__c','Destination_Org__c','Groups__c','Queues__c','Status__c','Permission_Set_Licenses__c'};        
        
        system.debug('3001000---$$$$$$$$$-AUPJSONGenerator:generateJSONContent:passed in message: '+eventMessage);
        // Write data to the JSON string.
        try {
            gen.writeStartObject();
            if (eventType.equals('User')) {
                gen.writeStringField('SECID', (String)eventMessage.get('AD_SEC_ID__c'));
                gen.writeStringField('FederationId', (String)eventMessage.get('AD_Federation_Id__c'));
                gen.writeStringField('Status', (String)eventMessage.get('Status__c'));
            } else if ( eventType.equals('Destination')) {
				//{AD_SEC_ID__c=000003, Email_Address__c=test_user20@email.com, Federation_Id__c=test_user20@email.com, 
				//FirstName__c=Test, LastName__c=User20, Profile_Name__c=Standard User, Role_Name__c=null, 
				//License_Name__c=Salesforce, Username__c=test_user20@email.com, Alias__c=TeUse, 
				//Permission_Set_Groups__c=, Permission_Sets__c=Base Platform Permissions&#124;, 
				//Destination_Org__c=VAEMPL, Groups__c=, Queues__c=, Permission_Set_Licenses__c=}
                for (String wSt1 : destNames) {
			        system.debug('3001100---$$$$$$$$$-AUPJSONGenerator:creating json string:name: '+wSt1+' value: '+(String)eventMessage.get(wSt1));
                    try {
                        if ( (String)eventMessage.get(wSt1) != null ) {
	                        gen.writeStringField(wSt1, (String)eventMessage.get(wSt1));
                        }
                    }catch(system.CalloutException e){            
                        system.debug('3001199---$$$$$$$$$-error:   '+e);
                        gen.writeStringField(wSt1, '');
                    }
                }
                /*
                gen.writeStringField('AD_SEC_ID__c', (String)eventMessage.get('AD_SEC_ID__c'));
                gen.writeStringField('Email_Address__c', (String)eventMessage.get('Email_Address__c'));
                gen.writeStringField('Federation_Id__c', (String)eventMessage.get('Federation_Id__c'));
                gen.writeStringField('FirstName__c"', (String)eventMessage.get('FirstName__c'));
                gen.writeStringField('LastName__c', (String)eventMessage.get('LastName__c'));
                gen.writeStringField('Profile_Name__c', (String)eventMessage.get('Profile_Name__c'));
                gen.writeStringField('Role_Name__c', (String)eventMessage.get('Role_Name__c'));
                gen.writeStringField('License_Name__c', (String)eventMessage.get('License_Name__c'));
                gen.writeStringField('Username__c', (String)eventMessage.get('Username__c'));
                gen.writeStringField('Alias__c', (String)eventMessage.get('Alias__c'));
                gen.writeStringField('Permission_Set_Groups__c', (String)eventMessage.get('Permission_Set_Groups__c'));
                gen.writeStringField('Permission_Sets__c', (String)eventMessage.get('Permission_Sets__c'));
                gen.writeStringField('Destination_Org__c', (String)eventMessage.get('Destination_Org__c'));
                gen.writeStringField('Groups__c', (String)eventMessage.get('Groups__c'));
                gen.writeStringField('Queues__c', (String)eventMessage.get('Queues__c'));
                gen.writeStringField('Permission_Set_Licenses__c', (String)eventMessage.get('Permission_Set_Licenses__c'));
				*/
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