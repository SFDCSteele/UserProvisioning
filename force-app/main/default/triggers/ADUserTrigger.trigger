trigger ADUserTrigger on AD_User__c (before insert, after insert, before update, after update) {
    /*
    System.debug('100.01-##############ADUserTrigger:processing: '+trigger.new);
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete){
            ADUserTriggerHandler.updateADUser(trigger.new);
        }
        //if(trigger.isDelete || trigger.isUpdate){
        if(trigger.isDelete){
            ADUserTriggerHandler.updateADUser(trigger.old);
        }
    }
	*/
}