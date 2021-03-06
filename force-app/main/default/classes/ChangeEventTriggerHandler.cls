public virtual class ChangeEventTriggerHandler {
    
    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    // Map containing all the different change event types
	private static List<String> changeTypes = new List<String> {'CREATE','UPDATE','DELETE','UNDELETE'};
    //private Map<String, List<ChangeEvent__e>> changeEvents;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
    
    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }
    
    // constructor
    public ChangeEventTriggerHandler() {
        this.setTriggerContext();
    }
    
    /***************************************
    * public instance methods
    ***************************************/
    
    // main method that will be called during execution
    public void run() {
        System.debug('ChangeEventTriggerHandler.run: starting: validateRun: '+validateRun()+' trigger context: '+this.context);
        
        if(!validateRun()) return;
        
        addToLoopCount();
        
        System.debug('%%%%%inside RUN trying to run: IdsToProcess   &&&&&&&&&');
        Map<String, List<Id>> IdsToProcess = getChangeEventIds();
        System.debug('%%%%%after IdsToProcess  : MAP: '+IdsToProcess+' &&&&&&&&&');
        
        // dispatch to the correct handler method
        //Loop throught change types and get the record ids for DML selects
        for (String ct : changeTypes ) {
            
	        System.debug('%%%%%inside RUN: looping through changeTypes: '+ct);
            if ( ct == 'CREATE' && IdsToProcess.get(ct) != null ) {            
                this.processCreate(IdsToProcess.get(ct));
            } else if ( ct == 'UPDATE' && IdsToProcess.get(ct) != null ) {
		        System.debug('%%%%%inside RUN: calling UPDATE changeTypes: '+ct);
                this.processUpdate(IdsToProcess.get(ct));
            } else if ( ct == 'DELETE' && IdsToProcess.get(ct) != null ) {
                this.processDelete(IdsToProcess.get(ct));
            } else if ( ct == 'UNDELETE' && IdsToProcess.get(ct) != null ) {
                this.processUndelete(IdsToProcess.get(ct));
            }
        }
        
        /*if(this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        } else if(this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
        } else if(this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        } else if(this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        } else if(this.context == TriggerContext.AFTER_UPDATE) {
            this.afterUpdate();
        } else if(this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        } else if(this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }*/
        
    }
    
    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if(!ChangeEventTriggerHandler.loopCountMap.containsKey(handlerName)) {
            ChangeEventTriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            ChangeEventTriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }
    
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }
    
    /***************************************
    * public static methods
    ***************************************/
    
    public static void bypass(String handlerName) {
        ChangeEventTriggerHandler.bypassedHandlers.add(handlerName);
    }
    
    public static void clearBypass(String handlerName) {
        ChangeEventTriggerHandler.bypassedHandlers.remove(handlerName);
    }
    
    public static Boolean isBypassed(String handlerName) {
        return ChangeEventTriggerHandler.bypassedHandlers.contains(handlerName);
    }
    
    public static void clearAllBypasses() {
        ChangeEventTriggerHandler.bypassedHandlers.clear();
    }
    
    /***************************************
    * private instancemethods
    ***************************************/
    
    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }
    
    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }
        
        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
           (ctx != null && ctx == 'before insert')) {
               this.context = TriggerContext.BEFORE_INSERT;
           } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                     (ctx != null && ctx == 'before update')){
                         this.context = TriggerContext.BEFORE_UPDATE;
                     } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                               (ctx != null && ctx == 'before delete')) {
                                   this.context = TriggerContext.BEFORE_DELETE;
                               } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                                         (ctx != null && ctx == 'after insert')) {
                                             this.context = TriggerContext.AFTER_INSERT;
                                         } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                                                   (ctx != null && ctx == 'after update')) {
                                                       this.context = TriggerContext.AFTER_UPDATE;
                                                   } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                                                             (ctx != null && ctx == 'after delete')) {
                                                                 this.context = TriggerContext.AFTER_DELETE;
                                                             } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                                                                       (ctx != null && ctx == 'after undelete')) {
                                                                           this.context = TriggerContext.AFTER_UNDELETE;
                                                                       }
    }
    
    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if(ChangeEventTriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = ChangeEventTriggerHandler.loopCountMap.get(handlerName).increment();
            if(exceeded) {
                Integer max = ChangeEventTriggerHandler.loopCountMap.get(handlerName).max;
                throw new ChangeEventTriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }
    
    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        if(!this.isTriggerExecuting || this.context == null) {
            throw new ChangeEventTriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        if(ChangeEventTriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }
        return true;
    }
    
    @TestVisible
    private String getHandlerName() {
        //|DEBUG|getHandlerName: ContactChangeEventTriggerHandler
        System.debug('getHandlerName: '+String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
    
    /***************************************
    * context methods
    ***************************************/
    
    // context-specific methods for override
    @TestVisible
    protected virtual void parseEventTypes(){}
    @TestVisible
    protected virtual Map<String, List<Id>> getChangeEventIds(){
        System.debug('#####inside virtual method########');
        return new Map<String, List<Id>>();
    }
    @TestVisible
    protected virtual void processCreate(List<Id> IdsToProcess){}
    @TestVisible
    protected virtual void processUpdate(List<Id> IdsToProcess){}
    @TestVisible
    protected virtual void processDelete(List<Id> IdsToProcess){}
    @TestVisible
    protected virtual void processUndelete(List<Id> IdsToProcess){}



	//
    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}
    
    /***************************************
* inner classes
***************************************/
    
    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;
        
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }
        
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }
        
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }
        
        public Boolean exceeded() {
            if(this.max < 0) return false;
            if(this.count > this.max) {
                return true;
            }
            return false;
        }
        
        public Integer getMax() {
            return this.max;
        }
        
        public Integer getCount() {
            return this.count;
        }
        
        public void setMax(Integer max) {
            this.max = max;
        }
    }
    
    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
            AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
            AFTER_UNDELETE
            }
    
    // exception class
    public class ChangeEventTriggerHandlerException extends Exception {}
    
}