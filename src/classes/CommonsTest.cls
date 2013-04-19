/**
 * 
 */
@isTest
private class CommonsTest {
	
    static testMethod void test_Commons_calculateResult_TestForms_Pass() {
        Test_Form__c testForm = TestUtilities.createTestForm(true);
        
        List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
        
        System.runAs(admins[0]) {
	        Test.startTest();
	        
	        Commons.resultClass result = Commons.calculateResult(testform);
	        
	        Test.stopTest();
	        
	        System.assertEquals(result.correctAnswers, TestUtilities.numberOfQuestions);
	        System.assert(result.pass);
        }
    }
    
    static testMethod void test_Commons_calculateResult_TestForms_Fail() {
        Test_Form__c testForm = TestUtilities.createTestForm(false);
		
		List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
        
        System.runAs(admins[0]) {
	        Test.startTest();
	        
	        Commons.resultClass result = Commons.calculateResult(testform);
	        
	        Test.stopTest();
	        
	        System.assertEquals(result.correctAnswers, 0);
	        System.assert(!result.pass);
        }
    }
    
    static testMethod void test_Commons_calculateResult_Examinations_Pass() {
        
        List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
        
        Examination__c examination = TestUtilities.createExamination(takers[0], true);
        
        System.runAs(takers[0]) {
	        Test.startTest();
	        
	        Commons.resultClass result = Commons.calculateResult(examination);
	        
	        Test.stopTest();
	        
	        System.assertEquals(result.correctAnswers, TestUtilities.numberOfQuestions);
	        System.assert(result.pass);
        }
    }
    
    static testMethod void test_Commons_calculateResult_Examinations_Fail() {
        List<User> takers = TestUtilities.getExamTakerUsers(1);
        insert takers;
        
        Examination__c examination = TestUtilities.createExamination(takers[0], false);
        
        System.runAs(takers[0]) {
	        Test.startTest();
	        
	        Commons.resultClass result = Commons.calculateResult(examination);
	        
	        Test.stopTest();
	        
	        System.assertEquals(result.correctAnswers, 0);
	        System.assert(!result.pass);
        }
    }
    
    static testMethod void test_Commons_next() {
							 
        QuestionAnswerWrapper questionWrapper = TestUtilities.createCorrectQuestion();
        Integer actualQuestion = 1;
        
        List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
        
        System.runAs(admins[0]) {
	        Test.startTest();
	        
	        Integer result = Commons.next(questionWrapper, actualQuestion);
	        
	        Test.stopTest();
	        
	        System.assertEquals(result,2);
        }
    }
    
    static testMethod void test_Commons_next_Exception() {
        QuestionAnswerWrapper questionWrapper = TestUtilities.createWrongQuestion();
        Integer actualQuestion = 1;
        Integer result;
        
        List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
        
        System.runAs(admins[0]) {
	        Test.startTest();
	        
	        try {
	        	result = Commons.next(questionWrapper, actualQuestion);
	        }
	        catch (Commons.InvalidNumberSelectedException invEx) {
	        	result = 9999;
	        }
	        
	        Test.stopTest();
	        
	        System.assertEquals(result,9999);
        }
    }
    
    static testMethod void test_Commons_previous() {
        QuestionAnswerWrapper questionWrapper = TestUtilities.createCorrectQuestion();
        Integer actualQuestion = 2;
        
        List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
        
        System.runAs(admins[0]) {
        	
	        Test.startTest();
	        
	        Integer result = Commons.previous(questionWrapper, actualQuestion);
	        
	        Test.stopTest();
	        
	        System.assertEquals(result,1);
        }
    }
    
    static testMethod void test_Commons_previous_Exception() {
		QuestionAnswerWrapper questionWrapper = TestUtilities.createWrongQuestion();
        Integer actualQuestion = 2;
        Integer result;
        
        List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
        
        System.runAs(admins[0]) {
	        Test.startTest();
	        
	        try {
	        	result = Commons.previous(questionWrapper, actualQuestion);
	        }
	        catch (Commons.InvalidNumberSelectedException invEx) {
	        	result = 9999;
	        }
	        
	        Test.stopTest();
	        
	        System.assertEquals(result,9999);
        }
    }
    
    static testMethod void test_Commons_review() {
        QuestionAnswerWrapper questionWrapper = TestUtilities.createCorrectQuestion();
        Integer actualQuestion = 1;
        
        List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
        
        System.runAs(admins[0]) {
	        Test.startTest();
	        
	        Boolean result = Commons.review(questionWrapper);
	        
	        Test.stopTest();
	        
	        System.assert(result);
        }
    }
    
    static testMethod void test_Commons_review_Exception() {
        QuestionAnswerWrapper questionWrapper = TestUtilities.createWrongQuestion();

        Boolean result;
        
        List<User> admins = TestUtilities.getExamAdminUsers(1);
        insert admins;
        
        System.runAs(admins[0]) {
	        Test.startTest();
	        
	        try {
	        	result = Commons.review(questionWrapper);
	        }
	        catch (Commons.InvalidNumberSelectedException invEx) {
	        	result = false;
	        }
	        
	        Test.stopTest();
	        
	        System.assert(!result);
        }
    }
    
    static testMethod void test_Commons_fillWrapperList() {
        List<Account> accounts = TestUtilities.createAccounts(1);
        insert accounts;
        List<Test_Form__c> testForms = TestUtilities.createTestForms(1, accounts[0].Id, 'Draft');
        insert testforms;
        List<Question__c> questions = TestUtilities.createQuestions(TestUtilities.numberOfQuestions, testForms[0].Id, true);
        insert questions;
        
        Test.startTest();
        
        List<QuestionAnswerWrapper> questionWrapperList = Commons.fillWrapperList(questions);
                
        Test.stopTest();
        
        System.assertEquals(questionWrapperList.size(),questions.size());
    }
    
    static testMethod void test_Commons_fillWrapperList_Empty() {
        
        List<Question__c> questions = new List<Question__c>();
        insert questions;
        
        Test.startTest();
        
        List<QuestionAnswerWrapper> questionWrapperList = Commons.fillWrapperList(questions);
                
        Test.stopTest();
        
        System.assertEquals(questionWrapperList.size(),0);
    }
}