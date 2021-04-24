public class ADGroupTriggerHandler {
    public static void updateADGroup(List<AD_Group__c> listOfADGroupsIds){
        System.debug('200.01-##############ADGroupTriggerHandler:processUpdate:List of AD Groups to process: '+listOfADGroupsIds);
        //Query all triggered Ad Group records        
        List<AD_Group_Update__e> groupEvents = new List<AD_Group_Update__e>();
        
        String parentGroupName = '';
        for(AD_Group__c grp: [SELECT Id, Name, RecordTypeId, Parent_AD_Group__c, AD_Group_Name__c, Status__c,AD_User__c 
                              FROM AD_Group__c where Id =: listOfADGroupsIds]){
            System.debug('102.05.100-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+
                         grp.AD_Group_Name__c+' Parent Group Id: '+grp.Parent_AD_Group__c+' user: '+grp.AD_User__c);
            parentGroupName = '';
            try {
                for(AD_Group__c parentGroup : [SELECT Id, Name, RecordTypeId, Parent_AD_Group__c, AD_Group_Name__c, Status__c 
                                               FROM AD_Group__c where Id =: grp.Parent_AD_Group__c]){
                    parentGroupName = parentGroup.AD_Group_Name__c;
                    System.debug('102.05.110-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+
                                 grp.AD_Group_Name__c+' Parent Group Name: '+parentGroup.AD_Group_Name__c);
                }
            } catch (NullPointerException npe) {
                System.debug('102.05.120-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+
                             grp.AD_Group_Name__c+' Parent_AD_Group__c: '+grp.Parent_AD_Group__c+' IS NULL!');
                
            }
            try {
                for(AD_User__c adUser : [SELECT AD_First_Name__c, AD_Last_Name__c, AD_User_Email__c, AD_Federation_Id__c 
                                         FROM AD_User__c where Id =: grp.AD_User__c]){
                    System.debug('102.05.130-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+
                                 grp.AD_Group_Name__c+' User: '+adUser.AD_First_Name__c+' '+adUser.AD_Last_Name__c);
                    groupEvents.add(new AD_Group_Update__e(
                        Group_Name__c=grp.AD_Group_Name__c,
                        Email_Address__c=adUser.AD_User_Email__c,
                        Federation_Id__c=adUser.AD_Federation_Id__c,
                        FirstName__c=adUser.AD_First_Name__c,
                        LastName__c=adUser.AD_Last_Name__c,
                        Parent_AD_Group__c=parentGroupName,
                        Status__c=grp.Status__c));                    
                }
            } catch (NullPointerException npe) {
                System.debug('102.05.140-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+
                             grp.AD_Group_Name__c+' AD_User__c: '+grp.AD_User__c+' IS NULL!');
                
            }
        }
        // Call method to publish events
        List<Database.SaveResult> srs = EventBus.publish(groupEvents);
        // Inspect publishing result
        for (Database.SaveResult sr: srs ) {
            if (sr.isSuccess()) {
                System.debug('102.01-##############ADGroupChangeEventTriggerHandler:processTransactions:Successfully published event: '+sr);
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
        }
        System.debug('102.05.190-##############ADGroupChangeEventTriggerHandler:processTransactions:FINISHING UP!');
    }

}