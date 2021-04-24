public class ADUserTriggerHandler {
    public static void updateADUser(List<AD_User__c> listOfADUsersIds){
        System.debug('200.01-##############ADUserTriggerHandler:processUpdate:List of AD Users to process: '+listOfADUsersIds);
        //Query all triggered Ad User records        
        List<AD_User__c> listOfADUsers = [SELECT Id, Name, CreatedDate, AD_Federation_Id__c, 
                                          AD_First_Name__c, AD_Last_Name__c, AD_User_Email__c, 
                                          Status__c FROM AD_User__c Where id IN :listOfADUsersIds];

        System.debug('202.01-##############ADUserTriggerHandler:processUpdate:FULL List of AD Users: '+listOfADUsers);
        List<AD_User_Inactivation__e> userEvents = new List<AD_User_Inactivation__e>();
        
        for (AD_User__c user : listOfADUsers) {
            userEvents.add(new AD_User_Inactivation__e(AD_Federation_Id__c=user.AD_Federation_Id__c, Status__c=user.Status__c));
        }
        System.debug('205.01-##############ADUserTriggerHandler:processUpdate:List of events to process: '+userEvents);
        // Call method to publish events
        List<Database.SaveResult> srs = EventBus.publish(userEvents);
        // Inspect publishing result
        for (Database.SaveResult sr: srs ) {
            if (sr.isSuccess()) {
                System.debug('210.01-##############ADUserTriggerHandler:processUpdate:Successfully published event: '+sr);
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
        }
    }
}