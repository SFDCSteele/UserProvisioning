trigger ADGroupTrigger on AD_Group__c (before insert, after insert, before update, after update) {
    System.debug('100.01-##############ADUserTrigger:processing: '+trigger.new);
    /*
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete){
            ADGroupTriggerHandler.updateADGroup(trigger.new);
        }
        if(trigger.isDelete || trigger.isUpdate){
            ADGroupTriggerHandler.updateADGroup(trigger.old);
        }
    }
	*/
}