public class ADUserChangeEventTriggerHandler extends ChangeEventTriggerHandler {
    
    
    // Map containing all the different change event types
    private Map<String, List<AD_User__ChangeEvent>> changeEvents;
    //this is a new method that could parse the events based on changetype, so each changeEvent could be processed differently
    public override void parseEventTypes() {
        String changeType = '';
        List<AD_User__ChangeEvent> eventArr = new List<AD_User__ChangeEvent>();
        for(AD_User__ChangeEvent event : (List<AD_User__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            
            if (changeEvents.isEmpty() || changeEvents.get(header.changetype) == null ) {
                eventArr = new List<AD_User__ChangeEvent>();
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
        
        //each team could either add fields to this SOQL or perform an additional SOQL based on their own criteria and then call their method/class
        //List<AD_User__c> ADUsers = [select Id,FirstName,LastName,RecordTypeId,AccountId from AD_User__c where Id= : IdsToProcess];
        
        //each team could place their calls here to process CREATED ADUsers
        //executeUserCheck(ADUsers);
    }
    
    private void executeUserCheck(List<AD_User__c> passedADUsers) {
        //User
        //Id userRecTypeId = Schema.SObjectType.AD_User__c.getRecordTypeInfosByName().get('ADUserMain').getRecordTypeId();
        
        //Account creation variables
        /*List<Account> newAccounts = new List<Account>();
        
        for (AD_User__c cont : passedADUsers) {
            
            if ( (cont.RecordTypeId == contUVRecTypeId || cont.RecordTypeId == contWHVRecTypeId) && cont.AccountId==null ) {
                newAccounts.add(new Account(Name = cont.FirstName + ' ' + cont.LastName, RecordTypeID = acctRecTypeId));                
            }
            
        }
        insert newAccounts;
        List<AD_User__c> updateADUsers = new List<AD_User__c>();
        //loop through the ADUsers, match up to the newly created accounts, adding the Id to the ADUser
        for (AD_User__c cont : passedADUsers) {
            
            if ( (cont.RecordTypeId == contUVRecTypeId || cont.RecordTypeId == contWHVRecTypeId) && cont.AccountId==null ) {
                for (Account acct: newAccounts ) {
                    //compName = cont.FirstName + ' ' + cont.LastName;
                    if ( acct.Name == (cont.FirstName + ' ' + cont.LastName) ) {
                        cont.AccountId = acct.Id;
                        updateAD_User__cs.add(cont);                        
                    }
                    
                }
            }
            
        }
        update updateADUsers;
        */
    }
    
    //This method takes all of the events in Trigger.new and maps the record Ids based on change type
    //***this can't be in the Virtual handler as events are typed based on which object it is
    //-----it may be required required to pull in the object based on new critera where the field in question did not actually change
    //--------like the field in question didn't change, but the record type changed which now requires us to look at that field
    public override Map<String, List<Id>> getChangeEventIds () {
        Map<String, List<Id>> recordIds = new Map<String, List<Id>>();
        String changeType = '';
        Id recordId;
        List<Id> recordArr = new List<Id>();
    	//Set<String> caseIds = new Set<String>();
        
        for(AD_User__ChangeEvent event : (List<AD_User__ChangeEvent>) Trigger.new) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            
            if (recordIds.isEmpty() || recordIds.get(header.changetype) == null ) {
                // Get all Record Ids for this change and add to the set
                //List<String> recordIds = change.ChangeEventHeader.getRecordIds();
                //caseIds.addAll(recordIds);
                recordArr = new List<Id>();
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                recordIds.put(header.changetype,recordArr); 
            } else {
                recordArr = recordIds.get(header.changetype);
                for (Id rId : header.recordIds) {
                    recordArr.add(rId);
                }
                recordIds.put(header.changetype,recordArr); 
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
        return recordIds;
    }
}