public class AppAccessChangeEventTriggerHandler extends ChangeEventTriggerHandler {
    
    
    // Map containing all the different change event types
    private Map<String, List<CF_Application_Access__ChangeEvent>> changeEvents;
    //this is a new method that could parse the events based on changetype, so each changeEvent could be processed differently
    public override void parseEventTypes() {
        System.debug('100.01->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:parseEventTypes:inside....');
        String changeType = '';
        List<CF_Application_Access__ChangeEvent > eventArr = new List<CF_Application_Access__ChangeEvent >();
        for(CF_Application_Access__ChangeEvent  event : (List<CF_Application_Access__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            System.debug('100.02->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:parseEventTypes:header:  '+header);
            
            if (changeEvents.isEmpty() || changeEvents.get(header.changetype) == null ) {
                eventArr = new List<CF_Application_Access__ChangeEvent>();
                eventArr.add(event);
                changeEvents.put(header.changetype,eventArr); 
            } else {
                eventArr = changeEvents.get(header.changetype);
                eventArr.add(event);
                changeEvents.put(header.changetype,eventArr); 
            }
        }      
    }
    
    
    public override void processCreate(List<Id> IdsToProcess) {
        System.debug('101.01->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:processCreate:inside....IdsToProcess: '+IdsToProcess);
        processTransactions(IdsToProcess);
        
    }
    
    public override void processUpdate(List<Id> IdsToProcess) {
        System.debug('101.02-##############AppAccessChangeEventTriggerHandler:processUpdate:inside....IdsToProcess: '+IdsToProcess);
        
        processTransactions(IdsToProcess);
    }
    
    
    public override void processDelete(List<Id> IdsToProcess) {
        System.debug('101.03-##############AppAccessChangeEventTriggerHandler:processDelete:inside....IdsToProcess: '+IdsToProcess);
        
        processTransactions(IdsToProcess);
    }
    
    private void processTransactions(List<Id> IdsToProcess) {
        System.debug('777.04-##############AppAccessChangeEventTriggerHandler:processTransactions:Ids: '+IdsToProcess);
                
        ADUpdateGroupService.createUser(IdsToProcess);

    }
    
    //This method takes all of the events in Trigger.new and maps the record Ids based on change type
    //***this can't be in the Virtual handler as events are typed based on which object it is
    //-----it may be required required to pull in the object based on new critera where the field in question did not actually change
    //--------like the field in question didn't change, but the record type changed which now requires us to look at that field
    public override Map<String, List<Id>> getChangeEventIds () {
        System.debug('104.01->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:getChangeEventIds:inside....');
        Map<String, List<Id>> recordIds = new Map<String, List<Id>>();
        String changeType = '';
        Id recordId;
        List<Id> recordArr = new List<Id>();
        List<String> changedFields = new List<String>();
        //Set<String> caseIds = new Set<String>();
        
        for(CF_Application_Access__ChangeEvent event : (List<CF_Application_Access__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            changedFields = header.getChangedFields();
            System.debug('104.02->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:getChangeEventIds:header: '+header+' changeType: '+header.changetype);
            System.debug('104.02.01->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:getChangeEventIds:changeType: '+header.changetype);
            System.debug('104.02.02->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:getChangeEventIds:changedFields: '+changedFields);
            
            if (recordIds.isEmpty() || recordIds.get(header.changetype) == null ) {
                // Get all Record Ids for this change and add to the set
                recordArr = new List<Id>();
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                //if ( changedFields.contains('Status__c') && event.get('Status__c') != 'New' ) {
                    System.debug('104.02.03->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:getChangeEventIds:Fields have changed: '+changedFields);
                    recordIds.put(header.changetype,recordArr); 
                //}
            } else {
                recordArr = recordIds.get(header.changetype);
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                //if ( changedFields.contains('Status__c') && event.get('Status__c') != 'New' ) {
                    System.debug('104.02.04->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:getChangeEventIds:Fields have changed: '+changedFields);
                    recordIds.put(header.changetype,recordArr); 
                //}
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
        System.debug('104.10->>>>>>>>>>>>AppAccessChangeEventTriggerHandler:getChangeEventIds:return recordIds: '+recordIds);
        return recordIds;
    }
    
}