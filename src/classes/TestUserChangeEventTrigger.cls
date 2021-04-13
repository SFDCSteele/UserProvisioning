@isTest
public class TestUserChangeEventTrigger {
    @isTest static void testCreateAndUpdateUser() {

        Test.enableChangeDataCapture();
        Id userRecTypeId = Schema.SObjectType.AD_User__c.getRecordTypeInfosByName().get('ADUserMain').getRecordTypeId();

        // Insert AD_User__c test records
        List<AD_User__c> newADUsers = new List<AD_User__c>();
        for (Integer i=0;i<5;i++) {
            
            newADUsers.add(new AD_User__c(AD_First_Name__c='cdcTest',
                               AD_Last_Name__c='Astro-'+i,
                               RecordTypeId=userRecTypeId,
                               AD_User_Email__c='test_'+i+'@email.com',
                               AD_Federation_Id__c='test_'+i+'_fedId@email.com',
                               Status__c='New'));
            
        }
        insert newADUsers;
        for (AD_User__c user: newADUsers) {
            System.debug('Newly inserted contact: '+user);
        }
        // Call deliver to fire the trigger and deliver the test change event.
        Test.getEventBus().deliver();
        // VERIFICATIONS
        // Check that the change event trigger created a task.
        AD_User__c[] userRecords = [SELECT Id, OwnerId, Name, RecordTypeId, AD_First_Name__c, AD_Last_Name__c, AD_User_Email__c, 
                                    AD_Federation_Id__c, Status__c FROM AD_User__c];
        System.assertEquals(5, userRecords.size(),
                            'The change event trigger did not create the expected users.');
        for (AD_User__c user: userRecords) {
            System.debug('Validating user Id: '+user);
        }
        System.debug('9999999.01--%%%%%%%%%%%%%%%testCreateAndUpdateUser:updated user: userRecords: '+userRecords);
        // Update user record
        // Test update with the first record
        AD_User__c user = userRecords[0];
        System.debug('9999999.02--%%%%%%%%%%%%%%%testCreateAndUpdateUser:updated user: user: '+user);
        // Debug
        System.debug('Retrieved AD_User__c record: ' + user);
        // Update one field and empty another
        user.AD_First_Name__c = 'Codey';
        user.Status__c = 'Inactive';
        System.debug('9999999.03--%%%%%%%%%%%%%%%testCreateAndUpdateUser:updated user: user: '+user);
        update user;
        System.debug('9999999.04--%%%%%%%%%%%%%%%testCreateAndUpdateUser:updated user: user: '+user);
        
        // Call deliver to fire the trigger for the update operation.
        Test.getEventBus().deliver();
        List<EventBusSubscriber> userEvents = [select Topic, Type, Name, Position, Retries, LastError FROM EventBusSubscriber WHERE Topic='AD_User__ChangeEvent' AND Type='ApexTrigger'];
        System.debug('9999999.09--%%%%%%%%%%%%%%%EventBusSubscriber:userEvents: '+userEvents);
        System.assertEquals(1, userEvents.size(),
                            'Platform event records did not created.');
        //14:09:52:421 USER_DEBUG [48]|DEBUG|EventBusSubscriber:userEvents: (EventBusSubscriber:{Topic=AD_Group__ChangeEvent, Type=ApexTrigger, Name=ADGroupChangeEventTrigger, Position=0, Retries=0, Id=000000000000000AAA, ExternalId=01q1F000000zbDh}, 
        //EventBusSubscriber:{Topic=AD_User__ChangeEvent, Type=ApexTrigger, Name=ADUserChangeEventTrigger, Position=6, Retries=0, Id=000000000000000AAA, ExternalId=01q1F000000zb9K})
    }
}