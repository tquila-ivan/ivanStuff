public without sharing class Commons {
	
	//Exception declaration
	public class InvalidNumberSelectedException extends Exception {}
	public class InvalidQuestionException extends Exception {}
	public class LimitationException extends Exception {}
	
	//Method that calculates the score of the exam or Test form and returns a wrapper class with the result
	public static resultClass calculateResult(sObject exam) {
		Integer correctAnswers = 0;
		Integer totalQuestions = 0;
		//Requery to make sure it's the last snapshot of the examination or Test Form
		
		String soqlQuery = 'Select (Select Correct__c from Questions__r),';
		Double passPercent;
		
		//Query Examinations
		if (exam.getsObjectType() == Examination__c.sObjectType) {
			soqlQuery += ' Test_Form__r.Passing_Score__c from Examination__c ';
			soqlQuery += ' where Id = \'' + exam.Id + '\'';
			Examination__c examination = Database.query(soqlQuery);
			examination.Examination_Status__c = 'Completed';
			passPercent = examination.Test_Form__r.Passing_Score__c;
			totalQuestions = examination.Questions__r.size();
			correctAnswers = getCorrectAnswers(examination.Questions__r);
		}
		
		//Query Test Forms
		if (exam.getsObjectType() == Test_Form__c.sObjectType) {
			soqlQuery += ' Passing_Score__c from Test_Form__c ';
			soqlQuery += ' where Id = \'' + exam.Id + '\'';
			Test_Form__c test_form = Database.query(soqlQuery);
			passPercent = test_form.Passing_Score__c;
			totalQuestions = test_form.Questions__r.size();
			correctAnswers = getCorrectAnswers(test_form.Questions__r);
		}
		
		//Calculate and return score		
		Double actualPercent = Double.valueOf(correctAnswers) / Double.valueOf(totalQuestions) * 100.0;
		
		return (new resultClass(actualPercent >= passPercent, correctAnswers));
	}
	
	//Method that returns the number of questions correctly answered
	private static Integer getCorrectAnswers (List<Question__c> questions) {
		Integer correctAnswers = 0;
		for(Question__c question : questions) {
			if (question.Correct__c == 1) {
				correctAnswers ++;
			}
		}
		return correctAnswers;
	}
	
	//Method that validates that the number of selected answers is the same as the number of correct answers
	private static void validateSelected(QuestionAnswerWrapper questionWrapper) {
		if (questionWrapper.getSelectedAnswers().size() != questionWrapper.question.Number_of_Correct_Answers__c) 
			throw new Commons.InvalidNumberSelectedException('Please select ' + questionWrapper.question.Number_of_Correct_Answers__c + ' answer(s)');
	}
	
	//Methos that populates a QuestionAnswer Wrapper list to handle exams and Test Forms
	public static List<QuestionAnswerWrapper> fillWrapperList (List<Question__c> questions) {
		List<QuestionAnswerWrapper> questionAnswerWrapperList = new List<QuestionAnswerWrapper>();
		
		for (Question__c quest : questions) {
			questionAnswerWrapperList.add(new QuestionAnswerWrapper(quest));
		}
		
		return questionAnswerWrapperList;
	}
	
	//Method that handles the action of pushing the next button
	public static Integer next(QuestionAnswerWrapper questionWrapper, Integer actualQuestion) {
		updateQuestion(questionWrapper);
		return actualQuestion + 1;
	}
	
	//Method that handles the action of pushing the previous button
	public static Integer previous(QuestionAnswerWrapper questionWrapper, Integer actualQuestion) {
		updateQuestion(questionWrapper);
		return actualQuestion - 1;
	}
	
	//Method that handles the action of pushing the review button
	public static Boolean review(QuestionAnswerWrapper questionWrapper) {
		updateQuestion(questionWrapper);
		return true;
	}
	
	//Method that updates the question, this is done in every action, I decided to do it this way to give the user the ability to exit and come back later and still have his answers.
	private static void updateQuestion(QuestionAnswerWrapper questionWrapper) {
		validateSelected(questionWrapper);
		update questionWrapper.getAnswers();
		update questionWrapper.question;
	}
	
	//Wrapper class for the result, with a boolean value and the number of questions correctly answered
	public class resultClass {
		public Boolean pass {get;set;}
		public Integer correctAnswers {get;set;}
		
		public resultClass (Boolean p, Integer cA) {
			pass = p;
			correctAnswers = cA;
		}
	}

}