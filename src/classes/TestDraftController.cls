public with sharing class TestDraftController {

	private Test_Form__c exam;
	private static final String draftStatus = 'Draft';
	
	public Boolean isDraft {get;set;}
	
	public Integer actualQuestion {
		get {
			if (actualQuestion == null)
				actualQuestion = 1;
			return actualQuestion;
		}
		set;
	}
	
	public String questionLabel{
		get {
			return String.format(System.Label.QuestionLabel, new List<String>{String.valueOf(actualQuestion), String.valueOf(questionCount)});
		}
	}
	
	public String selectLabel{
		get {
			return String.format(System.Label.SelectLabel, new List<String>{String.valueOf(questionWrapper.question.Number_of_Correct_Answers__c)});
		}
	}
	
	public List<QuestionAnswerWrapper> questionAnswerWrapperList {
		get {
			if (questionAnswerWrapperList == null)
				questionAnswerWrapperList = new List<QuestionAnswerWrapper>();
			return questionAnswerWrapperList;
		}
		set;
	}
	public QuestionAnswerWrapper questionWrapper {
		get {
			if (questionCount >= actualQuestion && actualQuestion > 0) {
				questionWrapper = questionAnswerWrapperList[actualQuestion - 1];
			}
			return questionWrapper;
		}
		set;
	}
	public Integer questionCount {get;set;}
	public Boolean isEmpty {get;set;}
	public Boolean isReview {
		get {
			if (isReview == null)
				isReview = false;
			return isReview;
		}
		set;
	}
	public Boolean isDone {get;set;}
	
	public String result {get;set;}
	
	public TestDraftController (ApexPages.StandardController stdController) {
		
		exam = (Test_Form__c) stdController.getRecord();
		
		//if (exam.Test_Status__c == draftStatus) {
			isDraft = true;
			List<Question__c> questions = [Select 
							Question__c, 
							Question_Number__c,
							Number_of_Correct_Answers__c,
							Number_Correctly_Selected__c,
							Mark_For_Review__c,
							(Select
								Number__c,
								Selected__c,
								Answer__c
							 from Answers__r
							 order by Number__c asc
							)
						 from Question__c
						 where Test_Form__c = :exam.Id
						 order by Question_Number__c asc
						];
			
			if (questions.size() == 0)
				isEmpty = true;
			else {
				questionAnswerWrapperList = Commons.fillWrapperList(questions);
				questionCount = questionAnswerWrapperList.size();
			}
		/*}
		else
			isDraft = false;*/
	}
	
	public void next() {
		try {
			actualQuestion = Commons.next(questionWrapper, actualQuestion);
		}
		catch (Commons.InvalidNumberSelectedException ex) {
			ApexPages.addMessages(ex);
		}
		catch (Exception exc) {
			ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.FATAL,'Please contact your administrator, an unexpected error has occurred');
			ApexPages.addMessage(message);
		}
	}
	
	public void previous() {
		try {
			actualQuestion = Commons.previous(questionWrapper, actualQuestion);
		}
		catch (Commons.InvalidNumberSelectedException ex) {
			ApexPages.addMessages(ex);
		}
		catch (Exception exc) {
			ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.FATAL,'Please contact your administrator, an unexpected error has occurred');
			ApexPages.addMessage(message);
		}
	}
	
	public void review() {
		try {
			isReview = Commons.review(questionWrapper, actualQuestion);
		}
		catch (Commons.InvalidNumberSelectedException ex) {
			ApexPages.addMessages(ex);
		}
		catch (Exception exc) {
			ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.FATAL,'Please contact your administrator, an unexpected error has occurred');
			ApexPages.addMessage(message);
		}
	}
	
	public void goToQuestion() {
		isReview = false;
	}
	
	public void finish () {
		
		if (isReview) {
			isDone = true;
			
			Commons.resultClass resultClass = Commons.calculateResult(exam);
			if (resultClass.pass) {
				result = String.format(System.Label.PassLabel, new List<String>{String.valueOf(resultClass.correctAnswers), String.valueOf(questionCount)});
			}
			else {
				result = String.format(System.Label.FailLabel, new List<String>{String.valueOf(resultClass.correctAnswers), String.valueOf(questionCount)});
			}
		}
		else
			review();
	}
}