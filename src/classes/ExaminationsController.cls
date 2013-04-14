public without sharing class ExaminationsController {

	private final Examination__c exam;
	public Integer actualQuestion {
		get {
			if (actualQuestion == null)
				actualQuestion = 0;
			return actualQuestion;
		}
		set;
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
				return questionAnswerWrapperList[actualQuestion - 1];
			}
			return questionWrapper;
		}
		set;
	}
	public Integer questionCount {get;set;}
	public Boolean isEmpty {get;set;}
	public Boolean isReview {get;set;}
	
	public ExaminationsController (ApexPages.StandardController stdController) {
		
		exam = (Examination__c) stdController.getRecord();
		//actualQuestion = 0;
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
					 where Examination__c = :exam.Id
					 order by Question_Number__c asc
					];
		questionCount = questions.size();
		if (questionCount == 0)
			isEmpty = true;
		else
			fillWrapperList(questions);
	}
	
	public void fillWrapperList (List<Question__c> questions) {
		for (Question__c quest : questions) {
			questionAnswerWrapperList.add(new QuestionAnswerWrapper(quest));
		}
	}
	
	public void start() {
		exam.Examination_Status__c = 'In Progress';
		update exam;
		actualQuestion = 1;
	}
	
	public void onLoad () {
		if (exam.Examination_Status__c != 'New' && actualQuestion == 0) {
			actualQuestion = 1;
		}
	}
	
	public void next() {
		try {
			validateSelected();
			//Should I or Shouldn't I save the answers???
			update questionWrapper.getAnswers();
			update questionWrapper.question;
			actualQuestion += 1;
		}
		catch (InvalidNumberSelectedException ex) {
			ApexPages.addMessages(ex);
		}
		catch (Exception exc) {
			ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.FATAL,'Please contact your administrator, an unexpected error has occurred');
			ApexPages.addMessage(message);
		}
	}
	
	public void previous() {
		try {
			validateSelected();
			update questionWrapper.getAnswers();
			update questionWrapper.question;
			actualQuestion -= 1;
		}
		catch (InvalidNumberSelectedException ex) {
			ApexPages.addMessages(ex);
		}
		catch (Exception exc) {
			ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.FATAL,'Please contact your administrator, an unexpected error has occurred');
			ApexPages.addMessage(message);
		}
	}
	
	public void review() {
		try {
			validateSelected();
			update questionWrapper.getAnswers();
			update questionWrapper.question;
			isReview = true;
		}
		catch (InvalidNumberSelectedException ex) {
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
	
	public void validateSelected() {
		if (questionWrapper.getSelectedAnswers().size() != questionWrapper.question.Number_of_Correct_Answers__c) 
			throw new InvalidNumberSelectedException('Please select ' + questionWrapper.question.Number_of_Correct_Answers__c + ' answer(s)');
	}
	
	public class InvalidNumberSelectedException extends Exception {}
}