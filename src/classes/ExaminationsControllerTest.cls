/**
 * Test class that tests the examination controller behaviour
 */
@isTest
private class ExaminationsControllerTest {

	//Common method to create controller
	private static ExaminationsController createController(User taker, Boolean passed) {
		
		Examination__c examination = TestUtilities.createExamination(taker, passed);
		ApexPages.StandardController standardCtlr = new ApexPages.Standardcontroller(examination);
		
		ExaminationsController examController = new ExaminationsController(standardCtlr);
		return examController;
	}
	
	//Test start exam
    static testMethod void test_ExaminationsController_start() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			ExaminationsController examController = createController(takers[0], true);
			Test.startTest();
			examController.start();
			Test.stopTest();
			System.assertEquals(examController.questionCount, TestUtilities.numberOfQuestions);
			System.assertEquals(examController.exam.Examination_Status__c, examController.progressStatus);
		}
    }
    
    //Test onload with a finished and passed exam
    static testMethod void test_ExaminationsController_onLoadPassed() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			ExaminationsController examController = createController(takers[0], true);
			examController.exam.Examination_Status__c = examController.completedStatus;
			Test.startTest();
			examController.onLoad();
			Test.stopTest();
			System.assert(examController.isReview);
			System.assert(examController.result.contains('PASSED'));
		}
    }
    
    //Test onload with a finished and failed exam
    static testMethod void test_ExaminationsController_onLoadFailed() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			ExaminationsController examController = createController(takers[0], false);
			examController.exam.Examination_Status__c = examController.completedStatus;
			Test.startTest();
			examController.onLoad();
			Test.stopTest();
			System.assert(examController.isReview);
			System.assert(examController.result.contains('FAILED'));
		}
    }
    
    //Test next functionality without problems
    static testMethod void test_ExaminationsController_nextOK() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			Test.startTest();
			ExaminationsController examController = createController(takers[0], false);
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
    static testMethod void test_ExaminationsController_next_GenericException() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			ExaminationsController examController = createController(takers[0], false);
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
    static testMethod void test_ExaminationsController_next_InvalidNumberException() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			ExaminationsController examController = createController(takers[0], false);
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
    
    //Text previous functionality without problems
    static testMethod void test_ExaminationsController_previousOK() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			Test.startTest();
			ExaminationsController examController = createController(takers[0], false);
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
    static testMethod void test_ExaminationsController_previous_GenericException() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			ExaminationsController examController = createController(takers[0], false);
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
    static testMethod void test_ExaminationsController_previous_InvalidNumberException() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			ExaminationsController examController = createController(takers[0], false);
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
    static testMethod void test_ExaminationsController_reviewOK() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			Test.startTest();
			ExaminationsController examController = createController(takers[0], false);
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
    static testMethod void test_ExaminationsController_review_GenericException() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			ExaminationsController examController = createController(takers[0], false);
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
    static testMethod void test_ExaminationsController_review_InvalidNumberException() {
		PageReference pageRef = Page.Examination;
		Test.setCurrentPageReference(pageRef);
		
		List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
		System.runAs(takers[0]) {
			ExaminationsController examController = createController(takers[0], false);
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