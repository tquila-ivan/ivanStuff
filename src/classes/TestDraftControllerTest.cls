/**
 * Test class that tests Test Draft controller functionality
 */
@isTest
private class TestDraftControllerTest {
	
	//Common method to create controller
	private static TestDraftController createController(Boolean passed) {
		
		Test_Form__c testForm = TestUtilities.createTestForm(passed);
		ApexPages.StandardController standardCtlr = new ApexPages.Standardcontroller(testForm);
		
		TestDraftController testController = new TestDraftController(standardCtlr);
		return testController;
	}
 
 	//Test next functionality without problems
    static testMethod void test_TestDraftController_nextOK() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			Test.startTest();
			TestDraftController examController = createController(false);
			examController.actualQuestion = 0;
			examController.questionWrapper = TestUtilities.createCorrectQuestion();
			examController.next();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assertEquals(errors.size(), 0);
			System.assertEquals(examController.actualQuestion,1);
		}
    }
    
    //Test next functionality with a generic exception
    static testMethod void test_TestDraftController_next_GenericException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			TestDraftController examController = createController(false);
			examController.actualQuestion = 0;
			examController.questionWrapper = null;
			Test.startTest();
			examController.next();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assert(errors.size() > 0);
		}
    }
    
    //Test next functionality with an invalid number exception
    static testMethod void test_TestDraftController_next_InvalidNumberException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			TestDraftController examController = createController(false);
			examController.actualQuestion = 1;
			examController.questionWrapper = TestUtilities.createWrongQuestion();
			Test.startTest();
			examController.next();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assertEquals(errors.size(), 0);
			System.assertEquals(examController.actualQuestion,1);
		}
    }
    
    //Test next functionality without problems
    static testMethod void test_TestDraftController_previousOK() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			Test.startTest();
			TestDraftController examController = createController(false);
			examController.actualQuestion = 0;
			examController.questionWrapper = TestUtilities.createCorrectQuestion();
			examController.previous();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assertEquals(errors.size(), 0);
			System.assertEquals(examController.actualQuestion,-1);
		}
    }
    
    //Test previous functionality with a generic exception
    static testMethod void test_TestDraftController_previous_GenericException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			TestDraftController examController = createController(false);
			examController.actualQuestion = 0;
			examController.questionWrapper = null;
			Test.startTest();
			examController.previous();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assert(errors.size() > 0);
		}
    }
    
    //Test previous functionality with an invalid number exception
    static testMethod void test_TestDraftController_previous_InvalidNumberException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			TestDraftController examController = createController(false);
			examController.actualQuestion = 1;
			examController.questionWrapper = TestUtilities.createWrongQuestion();
			Test.startTest();
			examController.previous();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assertEquals(errors.size(), 0);
			System.assertEquals(examController.actualQuestion,1);
		}
    }

	//Test review functionality without problems
    static testMethod void test_TestDraftController_reviewOK() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			Test.startTest();
			TestDraftController examController = createController(false);
			examController.actualQuestion = 0;
			examController.questionWrapper = TestUtilities.createCorrectQuestion();
			examController.review();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assertEquals(errors.size(), 0);
			System.assert(examController.isReview);
		}
    }
    
    //Test review functionality with a generic exception
    static testMethod void test_TestDraftController_review_GenericException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			TestDraftController examController = createController(false);
			examController.actualQuestion = 0;
			examController.questionWrapper = null;
			Test.startTest();
			examController.review();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assert(errors.size() > 0);
		}
    }
 	
 	//Test review functionality with an invalid number exception
    static testMethod void test_TestDraftController_review_InvalidNumberException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			TestDraftController examController = createController(false);
			examController.actualQuestion = 1;
			examController.questionWrapper = TestUtilities.createWrongQuestion();
			Test.startTest();
			examController.review();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assertEquals(errors.size(), 0);
			System.assert(!examController.isReview);
		}
    }
    
    //Test next functionality with a passed result
    static testMethod void test_ExaminationsController_finishPassed() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			TestDraftController examController = createController(true);
			examController.exam.Test_Status__c = examController.draftStatus;
			examController.isReview = true;
			Test.startTest();
			examController.finish();
			Test.stopTest();
			System.assert(examController.isReview);
			System.assert(examController.result.contains('PASSED'));
		}
    }
    
    //Test finish functionality with a failed result
    static testMethod void test_ExaminationsController_finishFailed() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			TestDraftController examController = createController(false);
			examController.exam.Test_Status__c = examController.draftStatus;
			examController.isReview = true;
			Test.startTest();
			examController.finish();
			Test.stopTest();
			System.assert(examController.isReview);
			System.assert(examController.result.contains('FAILED'));
		}
    }
    
    //Test finish functionality going to review
    static testMethod void test_ExaminationsController_finishReview() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
		System.runAs(admins[0]) {
			TestDraftController examController = createController(false);
			examController.exam.Test_Status__c = examController.draftStatus;
			examController.isReview = false;
			Test.startTest();
			examController.finish();
			Test.stopTest();
			System.assertEquals(examController.result,null);
		}
    }
}