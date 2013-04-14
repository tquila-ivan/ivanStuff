public with sharing class QuestionAnswerWrapper {

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
				if (result == question.Question_Number__c + '. ')
					result += ansW.letter;
				else
					result += ' ' + ansW.letter;
			}
			return result;
		}
		set;
	}
	
	public QuestionAnswerWrapper (Question__c originalQuestion) {
		question = originalQuestion;
		for (Answer__c ans : originalQuestion.Answers__r) {
			answerWrapperList.add(new AnswerWrapper(ans));
		}
	}
	
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
	
	public class AnswerWrapper {
		public String letter {
			get {
				return integerLetter.get(answer.Number__c);
			}
		}
		
		public String letterAndAnswer {
			get {
				return letter + '. ' + answer.Answer__c;
			}
		}
		
		public Answer__c answer {get;set;}
		
		private Map<Decimal,String> integerLetter = new Map<Decimal,String>();
		
		public AnswerWrapper (Answer__c ans) {
			answer = ans;
			integerLetter.put(1,'A');
			integerLetter.put(2,'B');
			integerLetter.put(3,'C');
			integerLetter.put(4,'D');
			integerLetter.put(5,'E');
			integerLetter.put(6,'F');
			integerLetter.put(7,'G');
			integerLetter.put(8,'H');
			integerLetter.put(9,'I');
			integerLetter.put(10,'J');
			integerLetter.put(11,'K');
			integerLetter.put(12,'L');
			integerLetter.put(13,'M');
			integerLetter.put(14,'N');
			integerLetter.put(15,'O');
			integerLetter.put(16,'P');
			integerLetter.put(17,'Q');
			integerLetter.put(18,'R');
			integerLetter.put(19,'S');
			integerLetter.put(20,'T');
			integerLetter.put(21,'U');
			integerLetter.put(22,'V');
			integerLetter.put(23,'W');
			integerLetter.put(24,'X');
			integerLetter.put(25,'Y');
			integerLetter.put(26,'Z');
		}
	}
}