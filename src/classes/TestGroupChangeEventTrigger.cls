@isTest
public class TestGroupChangeEventTrigger {
    @isTest static void testCreateAndUpdateGroup() {
        
        List<String> groupNames = new List<String>{'Salesforce','OHRS-VHA','Supervisor'};

        Test.enableChangeDataCapture();
        Id userRecTypeId = Schema.SObjectType.AD_User__c.getRecordTypeInfosByName().get('ADUserMain').getRecordTypeId();
        Id groupRecTypeId = Schema.SObjectType.AD_Group__c.getRecordTypeInfosByName().get('ADGroupMain').getRecordTypeId();

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
        // Insert AD_Group__c test records
        List<AD_Group__c> newADGroups_1 = new List<AD_Group__c>();
        List<AD_Group__c> newADGroups_2 = new List<AD_Group__c>();
        ID pGroupId;// = new ID();
        Integer cnt = 0;
        for (AD_User__c newUser: newADUsers) {
            for (String grp: groupNames ) {
                
                newADGroups_1.add(new AD_Group__c(AD_Group_Name__c=grp,
                                   AD_User__c=newUser.Id,
                                   RecordTypeId=groupRecTypeId,
                                   Status__c='New'));
                
            }
        }
        insert newADGroups_1;

        // Call deliver to fire the trigger and deliver the test change event.
        Test.getEventBus().deliver();

        for (AD_Group__c grp: newADGroups_1) {
	        grp.Status__c = 'Active';
            if ( (cnt++) > 0 ) {
                grp.Parent_AD_Group__c = pGroupId;
            } 
            if ( cnt > 3 ) {
                cnt=0;
                pGroupId = null;
            }
            pGroupId = grp.Id;
            System.debug('Updated group: '+ grp);
            newADGroups_2.add(grp);
        }
        update newADGroups_2;
        // Call deliver to fire the trigger and deliver the test change event.
        Test.getEventBus().deliver();
        List<EventBusSubscriber> groupEvents = [select Topic, Type, Name, Position, Retries, LastError FROM EventBusSubscriber WHERE Topic='AD_Group__ChangeEvent' AND Type='ApexTrigger'];
        System.debug('9999999.01--%%%%%%%%%%%%%%%EventBusSubscriber:groupEvents PASS 1: '+groupEvents);
        System.assertEquals(1, groupEvents.size(),
                            'Platform event records did not created.');
        // VERIFICATIONS
        // Check that the change event trigger created a task.
        // SELECT Id, Name, RecordTypeId, Parent_AD_Group__c, AD_Group_Name__c, Status__c, AD_User__c FROM AD_Group__c
        AD_Group__c[] groupRecords = [SELECT Id, Name, RecordTypeId, Parent_AD_Group__c, AD_Group_Name__c, Status__c, AD_User__c FROM AD_Group__c];
        System.assertEquals(15, groupRecords.size(),
                            'The change event trigger did not create the expected groups.');
        for (AD_Group__c grp: groupRecords) {
            System.debug('Validating group Id: '+grp);
        }
        System.debug('9999999.02--%%%%%%%%%%%%%%%testCreateAndUpdateGroup:updated group: groupRecords: '+groupRecords);
        // Update group record
        // Test update with the first record
        AD_Group__c grp = groupRecords[0];
        System.debug('9999999.03--%%%%%%%%%%%%%%%testCreateAndUpdateGroup:updated group: group: '+grp);
        // Debug
        System.debug('Retrieved AD_Group__c record: ' + grp);
        // Update one field and empty another
        grp.Status__c = 'Inactive';
        System.debug('9999999.04--%%%%%%%%%%%%%%%testCreateAndUpdateGroup:updated group: group: '+grp);
        update grp;
        System.debug('9999999.05--%%%%%%%%%%%%%%%testCreateAndUpdateGroup:updated group: group: '+grp);
        
        // Call deliver to fire the trigger for the update operation.
        Test.getEventBus().deliver();
        groupEvents = [select Topic, Type, Name, Position, Retries, LastError FROM EventBusSubscriber WHERE Topic='AD_Group__ChangeEvent' AND Type='ApexTrigger'];
        System.debug('9999999.09--%%%%%%%%%%%%%%%EventBusSubscriber:groupEvents PASS 2: '+groupEvents);
        System.assertEquals(1, groupEvents.size(),
                            'Platform event records did not created.');
        //14:09:52:421 group_DEBUG [48]|DEBUG|EventBusSubscriber:groupEvents: (EventBusSubscriber:{Topic=AD_Group__ChangeEvent, Type=ApexTrigger, Name=ADGroupChangeEventTrigger, Position=0, Retries=0, Id=000000000000000AAA, ExternalId=01q1F000000zbDh}, 
        //EventBusSubscriber:{Topic=AD_Group__ChangeEvent, Type=ApexTrigger, Name=ADGroupChangeEventTrigger, Position=6, Retries=0, Id=000000000000000AAA, ExternalId=01q1F000000zb9K})
    }
}