public class ADCreateUpdateUser {
    
    public ADCreateUpdateUser(){
    }
    /*
        ADCreateUpdateUser obj = new ADCreateUpdateUser();
        obj.execute();
     */
    
    public void execute(){
        Id userRecTypeId = Schema.SObjectType.AD_User__c.getRecordTypeInfosByName().get('ADUserMain').getRecordTypeId();

        // Insert AD_User__c test records
        String lastName = 'TEST-'+Datetime.now().format('yyyy-MM-dd_HH_mm_ss');
        AD_User__c newADUser = new AD_User__c(AD_First_Name__c='cdcTest',
                               AD_Last_Name__c=lastName,
                               RecordTypeId=userRecTypeId,
                               AD_User_Email__c='test_'+lastName+'@email.com',
                               AD_Federation_Id__c='test_'+lastName+'_fedId@email.com',
                               Status__c='New');
            
        insert newADUser;
        System.debug('ADCreateUpdateUser: Newly inserted contact: '+newADUser);
        // Update user record
        // Test update with the first record
        AD_User__c user = newADUser;
        System.debug('9999999.02--%%%%%%%%%%%%%%%ADCreateUpdateUser:updated user: user: '+user);
        // Debug
        System.debug('Retrieved AD_User__c record: ' + user);
        // Update one field and empty another
        user.AD_First_Name__c = 'Codey';
        user.Status__c = 'Inactive';
        System.debug('9999999.03--%%%%%%%%%%%%%%%ADCreateUpdateUser:updated user: user: '+user);
        update user;
        System.debug('9999999.04--%%%%%%%%%%%%%%%ADCreateUpdateUser:updated user: user: '+user);
        List<EventBusSubscriber> userEvents = [select Topic, Type, Name, Status, Position, Retries, LastError FROM EventBusSubscriber WHERE Topic='AD_User__ChangeEvent' AND Type='ApexTrigger'];
        System.debug('9999999.09--%%%%%%%%%%%%%%%ADCreateUpdateUser:EventBusSubscriber:userEvents('+userEvents.size()+'): '+userEvents);
        
    }
 }