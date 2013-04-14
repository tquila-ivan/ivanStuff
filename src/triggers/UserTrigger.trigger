trigger UserTrigger on User (after insert, after update) {

    //Create the Handler instance passing the proper parameters
    UserTriggerHandler handler = new UserTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if (trigger.isAfter && trigger.isInsert) {
        handler.OnAfterInsert(trigger.new);
    }
  
  //Uncomment for tests  
   // if (trigger.isAfter && trigger.isUpdate) {
   //     handler.OnAfterInsert(trigger.new);
   // }
}