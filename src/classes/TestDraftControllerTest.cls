/**
 * 
 */
@isTest
private class TestDraftControllerTest {
	
	private static TestDraftController createController(Boolean passed) {
		
		Test_Form__c testForm = TestUtilities.createTestForm(passed);
		ApexPages.StandardController standardCtlr = new ApexPages.Standardcontroller(testForm);
		
		TestDraftController testController = new TestDraftController(standardCtlr);
		return testController;
	}
/*
    static testMethod void test_TestDraftController_start() {
		PageReference pageRef = Page.TestDraftPagePage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			TestDraftController examController = createController(takers[0], true);
			Test.startTest();
			examController.start();
			Test.stopTest();
			System.assertEquals(examController.questionCount, TestUtilities.numberOfQuestions);
			System.assertEquals(examController.exam.TestDraft_Status__c, examController.progressStatus);
		}
    }
    
    static testMethod void test_TestDraftController_onLoadPassed() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			TestDraftController examController = createController(takers[0], true);
			examController.exam.TestDraft_Status__c = examController.completedStatus;
			Test.startTest();
			examController.onLoad();
			Test.stopTest();
			System.assert(examController.isReview);
			System.assert(examController.result.contains('PASSED'));
		}
    }
    
    static testMethod void test_TestDraftController_onLoadFailed() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			TestDraftController examController = createController(takers[0], false);
			examController.exam.TestDraft_Status__c = examController.completedStatus;
			Test.startTest();
			examController.onLoad();
			Test.stopTest();
			System.assert(examController.isReview);
			System.assert(examController.result.contains('FAILED'));
		}
    }
    
    static testMethod void test_TestDraftController_nextOK() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			Test.startTest();
			TestDraftController examController = createController(takers[0], false);
			examController.actualQuestion = 0;
			examController.questionWrapper = TestUtilities.createCorrectQuestion();
			examController.next();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assertEquals(errors.size(), 0);
			System.assertEquals(examController.actualQuestion,1);
		}
    }
    
    static testMethod void test_TestDraftController_next_GenericException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			TestDraftController examController = createController(takers[0], false);
			examController.actualQuestion = 0;
			examController.questionWrapper = null;
			Test.startTest();
			examController.next();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assert(errors.size() > 0);
		}
    }
    
    static testMethod void test_TestDraftController_next_InvalidNumberException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			TestDraftController examController = createController(takers[0], false);
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
    
    static testMethod void test_TestDraftController_previousOK() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			Test.startTest();
			TestDraftController examController = createController(takers[0], false);
			examController.actualQuestion = 0;
			examController.questionWrapper = TestUtilities.createCorrectQuestion();
			examController.previous();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assertEquals(errors.size(), 0);
			System.assertEquals(examController.actualQuestion,-1);
		}
    }
    
    static testMethod void test_TestDraftController_previous_GenericException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			TestDraftController examController = createController(takers[0], false);
			examController.actualQuestion = 0;
			examController.questionWrapper = null;
			Test.startTest();
			examController.previous();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assert(errors.size() > 0);
		}
    }
    
    static testMethod void test_TestDraftController_previous_InvalidNumberException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			TestDraftController examController = createController(takers[0], false);
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

    static testMethod void test_TestDraftController_reviewOK() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			Test.startTest();
			TestDraftController examController = createController(takers[0], false);
			examController.actualQuestion = 0;
			examController.questionWrapper = TestUtilities.createCorrectQuestion();
			examController.review();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assertEquals(errors.size(), 0);
			System.assert(examController.isReview);
		}
    }
    
    static testMethod void test_TestDraftController_review_GenericException() {
		PageReference pageRef = Page.TestDraftPage;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			TestDraftController examController = createController(takers[0], false);
			examController.actualQuestion = 0;
			examController.questionWrapper = null;
			Test.startTest();
			examController.review();
			Test.stopTest();
			
			List<ErrorLog__c> errors = [Select Id from ErrorLog__c limit 1];
			System.assert(errors.size() > 0);
		}
    }
  */  
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
}