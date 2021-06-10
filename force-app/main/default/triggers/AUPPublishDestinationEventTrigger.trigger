trigger AUPPublishDestinationEventTrigger on AUP_Destination_User_Event__e (after insert) {
    AUPPublishDestinationEvent.processUserEvents(Trigger.new);
}