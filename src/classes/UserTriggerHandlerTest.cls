/**
 * Test class for the UserTrigger Handler
 */
@isTest
private class UserTriggerHandlerTest {
	//Property to provoke an invalid Id exception
	private static final String fakeAccount = '0000';

	//Test method that evaluates that everything wnet correctly
    static testMethod void testBulkInsertOk() {
        List<User> usersToInsert = TestUtilities.createBulkData(null);
        Boolean success = true;
        Test.startTest();
        try {
        	insert usersToInsert;
        }
        catch(Exception ex) {
        	success = true;
        }
        Test.stopTest();
        
        List<Examination__c> examinationsCreated = [Select Id from Examination__c];
        System.assert(success);
        System.assertEquals(examinationsCreated.size(),TestUtilities.numberOfTestForms * usersToInsert.size());
    }
    
    //Test method that evaluates that an exception occurred
    static testMethod void testBulkInsertException() {
        List<User> usersToInsert = TestUtilities.createBulkData(fakeAccount);
        Boolean success = true;
        Test.startTest();
        try {
        	insert usersToInsert;
        }
        catch (Exception ex) {
        	success = false;
        }
        Test.stopTest();
        
        List<Examination__c> examinationsCreated = [Select Id from Examination__c];
        System.assert(!success);
        System.assertEquals(examinationsCreated.size(),0);
    }
}