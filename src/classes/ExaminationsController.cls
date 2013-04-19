/*
 * Class that controls the behaviour of the Examination Page, this allows Exam Taker users to
 * take their examinations properly.
 * I used a different controller and page for Examinations and Test Forms in order to allow tailoring
 * of the experience of Takers and Administrators, having differences regarding the Status management, the question 
 * and answer numbers, giving the possibility to close the window at any time, and any other future different behaviour needed
 * Being that so, I created a Commons class that has the common methods used by both of the controllers and that provide the main
 * functionalities of a test, providing ability to reuse for other different test experiences.  
 */
public without sharing class ExaminationsController {

	//Declaration of properties
	public Examination__c exam;
	public String completedStatus = 'Completed';
	public String progressStatus {
		get {
			return 'In Progress';
		}
	}
	
	private String newStatus = 'New';
	
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
	
	//Constructor of the class
	public ExaminationsController (ApexPages.StandardController stdController) {
		
		exam = (Examination__c) stdController.getRecord();

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
		if (questions.size() == 0)
			isEmpty = true;
		else {
			questionAnswerWrapperList = Commons.fillWrapperList(questions);
			questionCount = questionAnswerWrapperList.size();
		}
	}
	
	//Start functionality
	public void start() {
		exam.Examination_Status__c = progressStatus;
		update exam;
		actualQuestion = 1;
	}
	
	//onLoad functionality (to manage an already finished exam)
	public void onLoad () {
		if(exam.Examination_Status__c == completedStatus)
		{
			isReview = true;
			finish();
		}	
	}
	
	//next() functionality
	public void next() {
		try {
			if (questionWrapper == null)
				throw new Commons.InvalidQuestionException(System.Label.InvalidQuestion);
			actualQuestion = Commons.next(questionWrapper, actualQuestion);
		}
		catch (Commons.InvalidNumberSelectedException ex) {
			ApexPages.addMessages(ex);
		}
		catch (Exception exc) {
			ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.FatalError);
			ApexPages.addMessage(message);
			
			//Create error log for the administrator to be able to know what happened
			ErrorLog__c errorLog = new ErrorLog__c(Object__c = Schema.SObjectType.Examination__c.getName(), Description__c = exc.getMessage() + ' -- Stack: ' + exc.getStackTraceString());
			insert errorLog;
		}
	}
	
	//previous() functionality
	public void previous() {
		try {
			if (questionWrapper == null)
				throw new Commons.InvalidQuestionException(System.Label.InvalidQuestion);
			actualQuestion = Commons.previous(questionWrapper, actualQuestion);
		}
		catch (Commons.InvalidNumberSelectedException ex) {
			ApexPages.addMessages(ex);
		}
		catch (Exception exc) {
			ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.FatalError);
			ApexPages.addMessage(message);
			
			//Create error log for the administrator to be able to know what happened
			ErrorLog__c errorLog = new ErrorLog__c(Object__c = Schema.SObjectType.Examination__c.getName(), Description__c = exc.getMessage() + ' -- Stack: ' + exc.getStackTraceString());
			insert errorLog;
		}
	}
	
	//review() functionality
	public void review() {
		try {
			if (questionWrapper == null)
				throw new Commons.InvalidQuestionException(System.Label.InvalidQuestion);
			isReview = Commons.review(questionWrapper);
		}
		catch (Commons.InvalidNumberSelectedException ex) {
			ApexPages.addMessages(ex);
		}
		catch (Exception exc) {
			ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.FATAL,System.Label.FatalError);
			ApexPages.addMessage(message);
			
			//Create error log for the administrator to be able to know what happened
			ErrorLog__c errorLog = new ErrorLog__c(Object__c = Schema.SObjectType.Examination__c.getName(), Description__c = exc.getMessage() + ' -- Stack: ' + exc.getStackTraceString());
			insert errorLog;
		}
	}
	
	//Remove review page and go to question
	public void goToQuestion() {
		isReview = false;
	}
	
	//If in the review page, calculate scores and finish, else, go to review
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
						
			exam.Examination_Status__c = completedStatus;
			update exam;
		}
		else
			review();
	}
}