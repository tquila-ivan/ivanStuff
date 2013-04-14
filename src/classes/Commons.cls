public with sharing class Commons {
	
	public class InvalidNumberSelectedException extends Exception {}
	
	public static resultClass calculateResult(sObject exam) {
		Integer correctAnswers = 0;
		Integer totalQuestions = 0;
		//Requery to make sure it's the last snapshot of the examination or Test Form
		
		String soqlQuery = 'Select (Select Number_of_Correct_Answers__c, Number_Correctly_Selected__c from Questions__r),';
		Double passPercent;
		
		if (exam.getsObjectType() == Examination__c.sObjectType) {
			soqlQuery += ' Test_Form__r.Passing_Score__c from Examination__c ';
			soqlQuery += ' where Id = \'' + exam.Id + '\'';
			Examination__c examination = Database.query(soqlQuery);
			examination.Examination_Status__c = 'Completed';
			passPercent = examination.Test_Form__r.Passing_Score__c;
			totalQuestions = examination.Questions__r.size();
			correctAnswers = getCorrectAnswers(examination.Questions__r);
		}
		
		if (exam.getsObjectType() == Test_Form__c.sObjectType) {
			soqlQuery += ' Passing_Score__c from Test_Form__c ';
			soqlQuery += ' where Id = \'' + exam.Id + '\'';
			Test_Form__c test_form = Database.query(soqlQuery);
			passPercent = test_form.Passing_Score__c;
			totalQuestions = test_form.Questions__r.size();
			correctAnswers = getCorrectAnswers(test_form.Questions__r);
		}
					
		Double actualPercent = Double.valueOf(correctAnswers) / Double.valueOf(totalQuestions) * 100.0;
		
		System.debug('Actual --- ' + actualPercent + ' --- PassP --- ' + passPercent);
		return (new resultClass(actualPercent >= passPercent, correctAnswers));
	}
	
	private static Integer getCorrectAnswers (List<Question__c> questions) {
		Integer correctAnswers = 0;
		for(Question__c question : questions) {
			if (question.Number_of_Correct_Answers__c == question.Number_Correctly_Selected__c) {
				correctAnswers ++;
			}
		}
		return correctAnswers;
	}
	
	private static void validateSelected(QuestionAnswerWrapper questionWrapper) {
		if (questionWrapper.getSelectedAnswers().size() != questionWrapper.question.Number_of_Correct_Answers__c) 
			throw new Commons.InvalidNumberSelectedException('Please select ' + questionWrapper.question.Number_of_Correct_Answers__c + ' answer(s)');
	}
	
	public static List<QuestionAnswerWrapper> fillWrapperList (List<Question__c> questions) {
		List<QuestionAnswerWrapper> questionAnswerWrapperList = new List<QuestionAnswerWrapper>();
		
		for (Question__c quest : questions) {
			questionAnswerWrapperList.add(new QuestionAnswerWrapper(quest));
		}
		
		return questionAnswerWrapperList;
	}
	
	public static Integer next(QuestionAnswerWrapper questionWrapper, Integer actualQuestion) {
		updateQuestion(questionWrapper);
		return actualQuestion + 1;
	}
	
	public static Integer previous(QuestionAnswerWrapper questionWrapper, Integer actualQuestion) {
		updateQuestion(questionWrapper);
		return actualQuestion - 1;
	}
	
	public static Boolean review(QuestionAnswerWrapper questionWrapper, Integer actualQuestion) {
		updateQuestion(questionWrapper);
		return true;
	}
	
	private static void updateQuestion(QuestionAnswerWrapper questionWrapper) {
		validateSelected(questionWrapper);
		update questionWrapper.getAnswers();
		update questionWrapper.question;
	}
	
	public class resultClass {
		public Boolean pass {get;set;}
		public Integer correctAnswers {get;set;}
		
		public resultClass (Boolean p, Integer cA) {
			pass = p;
			correctAnswers = cA;
		}
	}

}