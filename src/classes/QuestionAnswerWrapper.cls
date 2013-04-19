/*
 * Class that wraps Questions and Answers together to handle them better
 */
public with sharing class QuestionAnswerWrapper {

	//Controlling properties
	public Question__c question {get;set;}
	public List<AnswerWrapper> answerWrapperList {
		get {
			if (answerWrapperList == null)
				answerWrapperList = new List<AnswerWrapper>();
			return answerWrapperList;
		}
		set;
	}
	public String reviewString {
		get {
			String result = '';
			result += question.Question_Number__c + ': ';
			for (AnswerWrapper ansW : getSelectedAnswers()) {
				if (result == question.Question_Number__c + ': ')
					result += ansW.letter;
				else
					result += ' ' + ansW.letter;
			}
			return result;
		}
		set;
	}
	
	//Constructor
	public QuestionAnswerWrapper (Question__c originalQuestion) {
		question = originalQuestion;
		for (Answer__c ans : originalQuestion.Answers__r) {
			answerWrapperList.add(new AnswerWrapper(ans));
		}
	}
	
	//Utility methods
	
	public List<Answer__c> getAnswers() {
		List<Answer__c> resultList = new List<Answer__c>();
		for (AnswerWrapper ansW : answerWrapperList) {
			resultList.add(ansW.answer);
		}
		return resultList;
	}
	
	public List<AnswerWrapper> getSelectedAnswers() {
		List<AnswerWrapper> resultList = new List<AnswerWrapper>();
		for (AnswerWrapper ansW : answerWrapperList) {
			if(ansW.answer.Selected__c)
				resultList.add(ansW);
		}
		return resultList;
	}
	
	//Answer wrapper class to map the numbers to letters using a Custom Setting to give flexibility in future
	// mappings to different characters
	public class AnswerWrapper {
		public String letter {
			get {
				if (integerLetter.containsKey(String.valueOf(answer.Number__c)))
					letter = integerLetter.get(String.valueOf(answer.Number__c)).letter__c;
				else
					letter = System.Label.AnswerNumberNotSet;
				return letter;
			}
			set;
		}
		
		public String letterAndAnswer {
			get {
				return letter + '. ' + answer.Answer__c;
			}
		}
		
		public Answer__c answer {get;set;}
		
		private Map<String,IntToLetter__c> integerLetter = new Map<String,IntToLetter__c>();
		
		public AnswerWrapper (Answer__c ans) {
			answer = ans;
			integerLetter = IntToLetter__c.getAll();
		}
	}
}