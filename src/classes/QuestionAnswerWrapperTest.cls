/**
 * 
 */
@isTest
private class QuestionAnswerWrapperTest {

	static testMethod void test_QuestionAnswerWrapper_getSelectedAnswers() {
        QuestionAnswerWrapper questionWrapper = TestUtilities.createCorrectQuestion();
        Test.startTest();
        Integer result = questionWrapper.getAnswers().size();
        Test.stopTest();

        System.AssertEquals(result,TestUtilities.numberOfAnswers);
    }
    
    static testMethod void test_QuestionAnswerWrapper_getAnswers() {
        
        QuestionAnswerWrapper questionWrapper = TestUtilities.createCorrectQuestion();
        
        Test.startTest();
        
        Integer result = questionWrapper.getSelectedAnswers().size();
        
        Test.stopTest();

        System.AssertEquals(result,TestUtilities.numberOfCorrectAnswers);
    }
    
    static testMethod void test_QuestionAnswerWrapper_getReviewString() {
        
        QuestionAnswerWrapper questionWrapper = TestUtilities.createCorrectQuestion();
        
        Test.startTest();
        
        String result = questionWrapper.reviewString;
        
        Test.stopTest();

        System.Assert(result.contains(System.Label.AnswerNumberNotSet));
    }
    
    static testMethod void test_QuestionAnswerWrapper_AnswerWrapper_getLetterAndAnswer() {
        List<sObject> ls = Test.loadData(IntToLetter__c.sObjectType, 'IntToLetterLoad');
        
        QuestionAnswerWrapper questionWrapper = TestUtilities.createCorrectQuestion();
        
        for (QuestionAnswerWrapper.AnswerWrapper ans : questionWrapper.answerWrapperList) {
        	System.Assert(!ans.letterAndAnswer.contains(System.Label.AnswerNumberNotSet));
        }

    }
    
}