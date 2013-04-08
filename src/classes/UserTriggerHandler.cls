public with sharing class UserTriggerHandler {
	
	private Boolean isExecuting = false;
    private Integer BatchSize = 0; 
    private Set<Id> questionIds = new Set<Id>();
    private List<Id> antiqueQuestions = new List<Id>();
    private List<Id> usersToShare = new List<Id>();
    private List<Id> usersToShareExaminations = new List<Id>();
    private List<Question__c> newQuestions = new List<Question__c>();
    private List<Answer__c> newAnswers = new List<Answer__c>();
	private List<Examination__c> newExaminations = new List<Examination__c>();
    private Map<Id,Id> oldQnewQ = new Map<Id,Id>();
    private Map<Id,Id> newQnewUser = new Map<Id,Id>();
    private Map<Id,Id> newExaminationNewUser = new Map<Id,Id>();
	private static final String takerProfileName = 'Custom: Exam Taker';
	private static final Integer maxInt = 100000;

	// CONSTRUCTOR
    public UserTriggerHandler(Boolean isExecuting, Integer size){
        isExecuting = isExecuting;
        BatchSize = size;
    }
    
    // AFTER INSERT
    public void OnAfterInsert(List<User> newUsers){
    	List<User> usersToProcess = new List<User>();
		Set<Id> accounts = new Set<Id>();
		
		Profile TakerProfileId = [Select Id from Profile where Name = :takerProfileName limit 1];
		
		for (User newUser : newUsers) {
			if (newUser.ProfileId == TakerProfileId.Id) {
				accounts.add(newUser.Account_Id__c);
				usersToProcess.add(newUser);
			}
		}
		
		if (usersToProcess.size() > 0)
			generateExaminations(usersToProcess, accounts);
    }
    
    public void generateExaminations(List<User> usersToProcess, Set<Id> accounts) {

    	List<Test_Form__c> openForms = new List<Test_Form__c>();
		Map<Id,Examination__c> formExaminationMap = new Map<Id,Examination__c>();
		Map<Id,List<Question__c>> formQuestionsMap = new Map<Id,List<Question__c>>();
		Set<Id> formIds = new Set<Id>();
		
		openForms = [Select
						Name,
						OwnerId,
						Account__c
					 from Test_Form__c
					 where Test_Status__c = 'Open' and Account__c in :accounts];
		
		for (Test_Form__c previousForm : openForms) {
			formIds.add(previousForm.Id);
		}
		
		List<Question__c> oldQuestions = [Select
										 	Name,
										 	Question__c,
										 	Test_Form__c,
										 	Test_Form__r.OwnerId,
										 	(Select
										 		Name,
												Answer__c,
												Correct__c,
												Number__c,
												Question__c
											 from Answers__r)
										  from Question__c
										  where Test_Form__c in :formIds
										 ];
		
		List<Question__c> tempQuestions = new List<Question__c>();
		for (Question__c oldQuestion : oldQuestions) {
			if (formQuestionsMap.get(oldQuestion.Test_Form__c) == null)
				formQuestionsMap.put(oldQuestion.Test_Form__c, new List<Question__c>{oldQuestion});
			else {
				tempQuestions = new List<Question__c>();
				tempQuestions = formQuestionsMap.get(oldQuestion.Test_Form__c);
				tempQuestions.add(oldQuestion);
				formQuestionsMap.put(oldQuestion.Test_Form__c,tempQuestions);
			}
		}
		
		//Begin Creation of objects:
		Examination__c tempExamination = new Examination__c();
		
		for (User newUser : usersToProcess) {
			for (Test_Form__c form : openForms) {
				if (newUser.Account_ID__c == form.Account__c) {
					tempExamination = new Examination__c();
					tempExamination.Name = newUser.FirstName + ' ' + newUser.LastName + ' - ' + form.Name;
					tempExamination.Test_Form__c = form.Id;
					tempExamination.Examination_Taker__c = newUser.Id;
					tempExamination.OwnerId = form.OwnerId;
					newExaminations.add(tempExamination);
					usersToShareExaminations.add(newUser.Id);
					generateQuestions(formQuestionsMap.get(form.Id), tempExamination.Name, newUser.Id);
				}
			}
		}
		
		insert newExaminations;
		insert newQuestions;
		
		System.assertEquals(newQuestions.size(),antiqueQuestions.size());
		System.assertEquals(newQuestions.size(),usersToShare.size());
		System.assertEquals(newExaminations.size(),usersToShareExaminations.size());
		
		List<Question__Share> qShares = new List<Question__Share>();
		for (Integer i = 0; i < newQuestions.size(); i++) {
			oldQnewQ.put(antiqueQuestions[i],newQuestions[i].Id);
			qShares.add(generateQuestionShare(newQuestions[i].Id,usersToShare[i]));
		}
		
		List<Examination__Share> exShares = new List<Examination__Share>(); 
		for (Integer j = 0; j < newExaminations.size(); j++) {
			exShares.add(generateExaminationShare(newExaminations[j].Id,usersToShareExaminations[j]));
		}

		generateAnswers(oldQuestions);
		
		insert newAnswers;
		
		insert exShares;
		insert qShares;

    }
    
    private void generateQuestions(List<Question__c> tempQuestionList, String ExaminationName, Id userIdToShare) {
		Integer tempListCount = tempQuestionList.size();
		Integer tempIndex;
		RandomValue random;
		Question__c tempQuestion = new Question__c();
		Question__c tempNewQuestion = new Question__c();
		
		for (Integer i = tempListCount;i>0; i--) {
			random = getRandomSObject(tempQuestionList);
			tempQuestion = (Question__c) random.value;
			tempIndex = random.index;
			tempNewQuestion = new Question__c();
			tempNewQuestion.Question__c = tempQuestion.Question__c;
			tempNewQuestion.Name = tempQuestion.Name;
			tempNewQuestion.Question_Number__c = i;
			tempNewQuestion.Examination__r = new Examination__c(Name = ExaminationName);
			tempNewQuestion.Test_Form__c = null;
			tempNewQuestion.OwnerId = tempQuestion.Test_Form__r.OwnerId;
			newQuestions.add(tempNewQuestion);
			antiqueQuestions.add(tempQuestion.Id);
			usersToShare.add(userIdToShare);
			tempQuestionList.remove(tempIndex);
		}
    }
    
    private void generateAnswers(List<Question__c> questions) {
    	Answer__c tempAnswer = new Answer__c();
    	Answer__c tempNewAnswer = new Answer__c();
    	List<Answer__c> tempAnswerList = new List<Answer__c>();
    	Integer tempListCount;
    	RandomValue random;
    	Integer tempIndex;
    	
    	for (Question__c question : questions) {
    		tempAnswerList = question.Answers__r;
    		tempListCount = tempAnswerList.size();
	    	for (Integer i = tempListCount;i>0; i--) {
	    		random = getRandomSObject(tempAnswerList);
				tempAnswer = (Answer__c) random.value;
				tempIndex = random.index;
	    		tempNewAnswer = new Answer__c();
	    		tempNewAnswer.Name = tempAnswer.Name;
	    		tempNewAnswer.Number__c = i;
	    		tempNewAnswer.Question__c = oldQnewQ.get(tempAnswer.Question__c);
	    		tempNewAnswer.Answer__c = tempAnswer.Answer__c;
	    		tempNewAnswer.Correct__c = tempAnswer.Correct__c;
	    		newAnswers.add(tempNewAnswer);
	    		tempAnswerList.remove(tempIndex);
	    	}
    	}
    }
    
    private Examination__Share generateExaminationShare(Id ParentId, Id UserOrGroupId) {
    	Examination__Share exShare = new Examination__Share();
    	exShare.ParentId = ParentId;
    	exShare.UserOrGroupId = UserOrGroupId;
    	exShare.AccessLevel = 'Read';
    	return exShare;
    }
    
    private Question__Share generateQuestionShare(Id ParentId, Id UserOrGroupId) {
    	Question__Share qShare = new Question__Share();
    	qShare.ParentId = ParentId;
    	qShare.UserOrGroupId = UserOrGroupId;
    	qShare.AccessLevel = 'Edit';
    	return qShare;
    }
    
    private Integer getRandomInteger(Integer max) {
    	Double d = math.random() * max;
		return d.intValue();
    }
    
    //Get's a random value from a list of questions
	private RandomValue getRandomSObject(List<sObject> sobjects){
		List<Double> ranks = new List<Double>();
		Map<Double,RandomValue> rankMap = new Map<Double,RandomValue>();
		Integer i = 0;
		for(sObject so  : sobjects){
			Boolean isDup = true;
			Double rank;
			While(isDup){
				Double x = getRandomInteger(maxInt);
				if(!rankMap.containsKey(x)){
					rank = x;
					isDup = false;
				}
			}
			ranks.add(rank);
			
			RandomValue rand = new RandomValue(i,so);
			rankMap.put(rank,rand);
			i++;
		}
		ranks.sort();
		return rankMap.get(ranks.get(0));
	}
	
	private class RandomValue {
		Integer index {get;set;}
		sObject value {get;set;}
		
		RandomValue (Integer i, sObject so) {
			index = i;
			value = so;
		}
	}
}