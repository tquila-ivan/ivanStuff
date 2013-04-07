public with sharing class UserTriggerHandler {
	
	private Boolean isExecuting = false;
    private Integer BatchSize = 0; 
    private Set<Id> questionIds = new Set<Id>();
    private List<Question__c> newQuestions = new List<Question__c>();
    private List<Answer__c> newAnswers = new List<Answer__c>();
	private List<Examination__c> newExaminations = new List<Examination__c>();
    
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
		
		System.debug('Entro');
    	List<Test_Form__c> openForms = new List<Test_Form__c>();
		Map<Id,Examination__c> formExaminationMap = new Map<Id,Examination__c>();
		
		openForms = [Select
						Name,
						(Select 
							Name,
							Test_Form__c,
							Question__c,
							Question_Number__c
						from Questions__r)
					 from Test_Form__c
					 where Test_Status__c = 'Open' and Account__c in :accounts];
		
		//Begin Creation of objects:
		Examination__c tempExamination = new Examination__c();
		
		for (User newUser : usersToProcess) {
			for (Test_Form__c form : openForms) {
				tempExamination = new Examination__c();
				tempExamination.Name = newUser.FirstName +  ' ' + newUser.LastName + ' - ' + form.Name;
				tempExamination.Test_Form__c = form.Id;
				tempExamination.Examination_Taker__c = newUser.Id;
				newExaminations.add(tempExamination);
				formExaminationMap.put(form.Id,tempExamination);
				generateQuestions(form.Questions__r, tempExamination.Name);
			}
		}
		
		Map<Id,Id> oldQnewQ = new Map<Id,Id>();
		
		insert formExaminationMap.values();
		insert newQuestions;

		newAnswers = [Select
						Answer__c,
						Correct__c,
						Number__c,
						Question__c
					 from Answer__c
					 where Question__c in :questionIds
					 ];

    }
    
    private void generateQuestions(List<Question__c> tempQuestionList, String ExaminationName) {
		Integer tempListCount = tempQuestionList.size();
		Integer tempIndex;
		RandomValue random;
		Question__c tempQuestion = new Question__c();
		Question__c tempNewQuestion = new Question__c();
		
		for (Integer i = tempListCount;i>0; i--) {
			random = getRandomSObject(tempQuestionList);
			tempQuestion = (Question__c) random.value;
			tempIndex = random.index;
			questionIds.add(tempQuestion.Id);
			tempNewQuestion = new Question__c();
			tempNewQuestion.Question__c = tempQuestion.Question__c;
			tempNewQuestion.Name = tempQuestion.Name;
			tempNewQuestion.Question_Number__c = i;
			tempNewQuestion.Examination__r = new Examination__c(Name = ExaminationName);
			tempNewQuestion.Test_Form__c = null;
			newQuestions.add(tempNewQuestion);
			tempQuestionList.remove(tempIndex);
		}
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