public class ADGroupChangeEventTriggerHandler extends ChangeEventTriggerHandler {
    
    
    // Map containing all the different change event types
    private Map<String, List<AD_Group__ChangeEvent>> changeEvents;
    //this is a new method that could parse the events based on changetype, so each changeEvent could be processed differently
    public override void parseEventTypes() {
        System.debug('100.01->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:parseEventTypes:inside....');
        String changeType = '';
        List<AD_Group__ChangeEvent> eventArr = new List<AD_Group__ChangeEvent>();
        for(AD_Group__ChangeEvent event : (List<AD_Group__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            System.debug('100.02->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:parseEventTypes:header:  '+header);
            
            if (changeEvents.isEmpty() || changeEvents.get(header.changetype) == null ) {
                eventArr = new List<AD_Group__ChangeEvent>();
                eventArr.add(event);
                changeEvents.put(header.changetype,eventArr); 
            } else {
                eventArr = changeEvents.get(header.changetype);
                eventArr.add(event);
                changeEvents.put(header.changetype,eventArr); 
            }
            //if (header.changetype == 'CREATE') {
            //}
        }      
    }
    
    
    public override void processCreate(List<Id> IdsToProcess) {
        System.debug('101.01->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:processCreate:inside....IdsToProcess: '+IdsToProcess);
        processTransactions(IdsToProcess);
        
    }
    
    public override void processUpdate(List<Id> IdsToProcess) {
        System.debug('102.01-##############ADGroupChangeEventTriggerHandler:processUpdate:inside....IdsToProcess: '+IdsToProcess);
        
        processTransactions(IdsToProcess);
    }
    
    
    public override void processDelete(List<Id> IdsToProcess) {
        System.debug('102.01-##############ADGroupChangeEventTriggerHandler:processDelete:inside....IdsToProcess: '+IdsToProcess);
        
        processTransactions(IdsToProcess);
    }
    
    private void processTransactions(List<Id> IdsToProcess) {
        System.debug('102.05-##############ADGroupChangeEventTriggerHandler:processTransactions:Ids: '+IdsToProcess);
        
        List<AD_Group_Update__e> groupEvents = new List<AD_Group_Update__e>();
        
        String parentGroupName = '';
        for(AD_Group__c grp: [SELECT Id, Name, RecordTypeId, Parent_AD_Group__c, AD_Group_Name__c, Status__c,AD_User__c FROM AD_Group__c where Id =: IdsToProcess]){
            System.debug('102.05.100-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+' Parent Group Id: '+grp.Parent_AD_Group__c+
                         ' user: '+grp.AD_User__c);
            parentGroupName = '';
            try {
                for(AD_Group__c parentGroup : [SELECT Id, Name, RecordTypeId, Parent_AD_Group__c, AD_Group_Name__c, Status__c FROM AD_Group__c where Id =: grp.Parent_AD_Group__c]){
                    parentGroupName = parentGroup.AD_Group_Name__c;
                    System.debug('102.05.110-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+' Parent Group Name: '+parentGroup.AD_Group_Name__c);
                }
            } catch (NullPointerException npe) {
                System.debug('102.05.120-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+' Parent_AD_Group__c: '+grp.Parent_AD_Group__c+' IS NULL!');
                
            }
            try {
                for(AD_User__c adUser : [SELECT AD_First_Name__c, AD_Last_Name__c, AD_User_Email__c, AD_Federation_Id__c FROM AD_User__c where Id =: grp.AD_User__c]){
                    System.debug('102.05.130-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+' User: '+adUser.AD_First_Name__c+' '+adUser.AD_Last_Name__c);
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
                System.debug('102.05.140-##############ADGroupChangeEventTriggerHandler:processTransactions:AD_Group_Name__c => '+grp.AD_Group_Name__c+' AD_User__c: '+grp.AD_User__c+' IS NULL!');
                
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
    
    //This method takes all of the events in Trigger.new and maps the record Ids based on change type
    //***this can't be in the Virtual handler as events are typed based on which object it is
    //-----it may be required required to pull in the object based on new critera where the field in question did not actually change
    //--------like the field in question didn't change, but the record type changed which now requires us to look at that field
    public override Map<String, List<Id>> getChangeEventIds () {
        System.debug('104.01->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:inside....');
        Map<String, List<Id>> recordIds = new Map<String, List<Id>>();
        String changeType = '';
        Id recordId;
        List<Id> recordArr = new List<Id>();
        List<String> changedFields = new List<String>();
        //Set<String> caseIds = new Set<String>();
        
        for(AD_Group__ChangeEvent event : (List<AD_Group__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            changedFields = header.getChangedFields();
            System.debug('104.02->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:header: '+header+' changeType: '+header.changetype);
            System.debug('104.02.01->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:changeType: '+header.changetype);
            System.debug('104.02.02->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:changedFields: '+changedFields);
            
            if (recordIds.isEmpty() || recordIds.get(header.changetype) == null ) {
                // Get all Record Ids for this change and add to the set
                recordArr = new List<Id>();
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                if ( changedFields.contains('Status__c') && event.get('Status__c') != 'New' ) {
                    System.debug('104.02.03->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:STATUS has changed: '+changedFields);
                    recordIds.put(header.changetype,recordArr); 
                }
            } else {
                recordArr = recordIds.get(header.changetype);
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                if ( changedFields.contains('Status__c') && event.get('Status__c') != 'New' ) {
                    System.debug('104.02.04->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:STATUS has changed: '+changedFields);
                    recordIds.put(header.changetype,recordArr); 
                }
            }
            //now put them in an 'ALL' type
            if (recordIds.isEmpty() || recordIds.get('ALL') == null ) {
                recordArr = new List<Id>();
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                recordIds.put('ALL',recordArr); 
            } else {
                recordArr = recordIds.get('ALL');
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                recordIds.put('ALL',recordArr); 
            }
        }      
        System.debug('104.10->>>>>>>>>>>>ADGroupChangeEventTriggerHandler:getChangeEventIds:return recordIds: '+recordIds);
        return recordIds;
    }
    
}