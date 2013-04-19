/*
 * Trigger that handles the creation of Users. On creation of the users this trigger calls
 * a handler class that will process the insertion in bulk to create the examinations if needed
 */
trigger UserTrigger on User (after insert, after update) {

    //Instantiate the Handler instance passing the proper parameters
    UserTriggerHandler handler = new UserTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    //Chack that the trigger event is after insert and call the handler method.
    if (trigger.isAfter && trigger.isInsert) {
        handler.OnAfterInsert(trigger.new);
    }
}