/*
 * Class that handles the events from the triggers for the User Object
 * For this assignment it will only handle the After Insert event to create examinations
 * for the users if they require so.
 */
public with sharing class UserTriggerHandler {
	
	//Declaration of properties and constants used in the handler
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
    	//Declare the list of users to be processed by the trigger
    	List<User> usersToProcess = new List<User>();
		Set<Id> accounts = new Set<Id>();
		
		//Query for the Exam Taker profile
		Profile TakerProfileId = [Select Id from Profile where Name = :takerProfileName limit 1];
		
		//Filter the users in the Trigger.new to just include the ones with the right profile and with a value in the Account Id field
		for (User newUser : newUsers) {
			try {
				if (newUser.ProfileId == TakerProfileId.Id && newUser.Account_ID__c != null) {
					//Populate Accounts and users to process
					accounts.add(newUser.Account_Id__c);
					usersToProcess.add(newUser);
				}
			}
			catch (Exception e) {
				//In case of error add error to only the user involved and continue with the rest
				newUser.addError(e.getMessage());
			}
		}
		
		//If there are users in the list, proceed to generate their examinations
		if (usersToProcess.size() > 0)
			generateExaminations(usersToProcess, accounts);
    }
    
    /*
     * Main Method that generates examinations for the users that require so.
     *
     * @param usersToProcess List of users to process
     * @param accounts Set of Account Ids of the users
     */ 
    public void generateExaminations(List<User> usersToProcess, Set<Id> accounts) {
		
		//Declare List, Maps and Sets to handle the different structures
    	List<Test_Form__c> openForms = new List<Test_Form__c>();
		Map<Id,Examination__c> formExaminationMap = new Map<Id,Examination__c>();
		Map<Id,List<Question__c>> formQuestionsMap = new Map<Id,List<Question__c>>();
		Set<Id> formIds = new Set<Id>();
		
		//Try generating the whole examinations and fail all users if some error happens inserting them.
		try {
			//Query Test Forms that are open from the accounts gathered from the new users to process
			openForms = [Select
							Name,
							OwnerId,
							Account__c
						 from Test_Form__c
						 where Test_Status__c = 'Open' and Account__c in :accounts];
			
			//Populate the set of Test Form Ids
			for (Test_Form__c previousForm : openForms) {
				formIds.add(previousForm.Id);
			}
			
			//Query old the data of the original questions from all the Test Forms needed
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
			
			//Populate a map that will be formed for a Test Form Id and the questions for that Test Form
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
			
			//Begin Creation of new objects
			Examination__c tempExamination = new Examination__c();
			
			//Loop the new Users to create each of them the examinations needed
			for (User newUser : usersToProcess) {
				//Loop the open Test Forms for every user
				for (Test_Form__c form : openForms) {
					//If the Test Form Account matches the User Account process the examination
					if (newUser.Account_ID__c == form.Account__c) {
						tempExamination = new Examination__c();
						//Populate Examination Details
						tempExamination.Name = newUser.FirstName + ' ' + newUser.LastName + ' - ' + form.Name;
						tempExamination.Test_Form__c = form.Id;
						tempExamination.Examination_Taker__c = newUser.Id;
						//The Owner is the same as the form's
						tempExamination.OwnerId = form.OwnerId;
						//Add new examination to list for insert 
						newExaminations.add(tempExamination);
						//Add the user id to share in a list in the same position as the examination, to be used later
						usersToShareExaminations.add(newUser.Id);
						//Generate questions for the Examination and the User to be shared with
						generateQuestions(formQuestionsMap.get(form.Id), tempExamination.Name, newUser.Id);
					}
				}
			}
			
			//Insert Examinations and questions created
			insert newExaminations;
			insert newQuestions;
			
			//Check that all lists have the same size, to use them afterwards in creating answers and shares
			System.assertEquals(newQuestions.size(),antiqueQuestions.size());
			System.assertEquals(newQuestions.size(),usersToShare.size());
			System.assertEquals(newExaminations.size(),usersToShareExaminations.size());
			
			//Share Questions and examinations with the proper users, to make them acessible for te users created
			
			//Set shares for the questions and populate map of old Id - New Id to link answers afterwards, using the lists created previously
			List<Question__Share> qShares = new List<Question__Share>();
			for (Integer i = 0; i < newQuestions.size(); i++) {
				oldQnewQ.put(antiqueQuestions[i],newQuestions[i].Id);
				qShares.add(generateQuestionShare(newQuestions[i].Id,usersToShare[i]));
			}
			
			//Set shares for the Examinations using the lists created previously
			List<Examination__Share> exShares = new List<Examination__Share>(); 
			for (Integer j = 0; j < newExaminations.size(); j++) {
				exShares.add(generateExaminationShare(newExaminations[j].Id,usersToShareExaminations[j]));
			}
			
			//Generate the answers for the questions
			generateAnswers(oldQuestions);
			
			//Insert Answers
			insert newAnswers;
			
			//Insert Shares
			insert exShares;
			insert qShares;
		}
		catch (Exception ex) {
			//In case of an error fail all users, show message to contact administrator
			for (User userError : usersToProcess) {
				userError.addError(System.Label.FatalError);
			}
			//Create error log for the administrator to be able to know what happened
			ErrorLog__c errorLog = new ErrorLog__c(Object__c = Schema.SObjectType.User.getName(), Description__c = ex.getMessage() + ' -- Stack: ' + ex.getStackTraceString());
			insert errorLog;
		}

    }
    
    /*
     * Method that generates questions for each of the new examinations
     *
     * @param tempQuestionList List of questions from the original form
     * @param ExaminationName The Examination's name to use as an external ID to link question to Examination
     * @param userIdToShare the user Id that needs to see the questions
     */ 
    private void generateQuestions(List<Question__c> tempQuestionList, String ExaminationName, Id userIdToShare) {
		//Declare and initialize control variables
		Integer tempListCount = tempQuestionList.size();
		Integer tempIndex;
		RandomValue random;
		Question__c tempQuestion = new Question__c();
		Question__c tempNewQuestion = new Question__c();
		
		//Loop the question list using indexes from higher to lower
		for (Integer i = tempListCount;i>0; i--) {
			//Get the random value and it's index in a wrapper class 
			random = getRandomSObject(tempQuestionList);
			tempQuestion = (Question__c) random.value;
			tempIndex = random.index;
			//Populate the new question with the values from the original question
			tempNewQuestion = new Question__c();
			tempNewQuestion.Question__c = tempQuestion.Question__c;
			tempNewQuestion.Name = tempQuestion.Name;
			tempNewQuestion.Question_Number__c = i;
			//Link question with examination with the name as a foreign key
			tempNewQuestion.Examination__r = new Examination__c(Name = ExaminationName);
			tempNewQuestion.Test_Form__c = null;
			tempNewQuestion.OwnerId = tempQuestion.Test_Form__r.OwnerId;
			//Populate new question List
			newQuestions.add(tempNewQuestion);
			//Populate old Ids to match new questions in the same random position (to be used in linking answers to questions afterwards)
			antiqueQuestions.add(tempQuestion.Id);
			//Populate a list of users in the same position as the questions, in order to link the shares afterwards
			usersToShare.add(userIdToShare);
			//Remove the question for the original temporal list, to continue randomizing
			tempQuestionList.remove(tempIndex);
		}
    }
    
    /*
     * Method that generates answers for all of the new examinations' questions
     *
     * @param questions List of questions from the original forms
     */ 
    private void generateAnswers(List<Question__c> questions) {
    	//Declare and initialize control variables
    	Answer__c tempAnswer = new Answer__c();
    	Answer__c tempNewAnswer = new Answer__c();
    	List<Answer__c> tempAnswerList = new List<Answer__c>();
    	Integer tempListCount;
    	RandomValue random;
    	Integer tempIndex;
    	
    	//Loop questions to generate answers in random orders
    	for (Question__c question : questions) {
    		//Get Answer list and count
    		tempAnswerList = question.Answers__r;
    		tempListCount = tempAnswerList.size();
    		//Loop answer in decreasing orders
	    	for (Integer i = tempListCount;i>0; i--) {
	    		//Get the random value and it's index in a wrapper class 
	    		random = getRandomSObject(tempAnswerList);
				tempAnswer = (Answer__c) random.value;
				tempIndex = random.index;
				//Populate the new answer with the values from the original answer
	    		tempNewAnswer = new Answer__c();
	    		tempNewAnswer.Name = tempAnswer.Name;
	    		tempNewAnswer.Number__c = i;
	    		//Link the original answer to the new question using the map created previously
	    		tempNewAnswer.Question__c = oldQnewQ.get(tempAnswer.Question__c);
	    		tempNewAnswer.Answer__c = tempAnswer.Answer__c;
	    		tempNewAnswer.Correct__c = tempAnswer.Correct__c;
	    		//Add new answer to insert list and remove from temporal one to continue randomizing
	    		newAnswers.add(tempNewAnswer);
	    		tempAnswerList.remove(tempIndex);
	    	}
    	}
    }
    
    /*
     * Method that generates a share object for Examination object
     *
     * @param ParentId Id of the examination to share
     * @param UserOrGroupId Id of the User to share with
     */ 
    private Examination__Share generateExaminationShare(Id ParentId, Id UserOrGroupId) {
    	Examination__Share exShare = new Examination__Share();
    	exShare.ParentId = ParentId;
    	exShare.UserOrGroupId = UserOrGroupId;
    	//Only grant Read only access
    	exShare.AccessLevel = 'Read';
    	return exShare;
    }
    
    /*
     * Method that generates a share object for Question object
     *
     * @param ParentId Id of the question to share
     * @param UserOrGroupId Id of the User to share with
     */ 
    private Question__Share generateQuestionShare(Id ParentId, Id UserOrGroupId) {
    	Question__Share qShare = new Question__Share();
    	qShare.ParentId = ParentId;
    	qShare.UserOrGroupId = UserOrGroupId;
    	//Grant Edit permissions, this is added because the profile states that Exam Takers have edit access on questions
    	qShare.AccessLevel = 'Edit';
    	return qShare;
    }
    
    /*
     * Method that generates a Random Integer up to a maximum value
     *
     * @param max Maximum value to generate the random Integer
     */ 
    private Integer getRandomInteger(Integer max) {
    	Double d = math.random() * max;
		return d.intValue();
    }
    
    /*
     * Method that gets a random value from a list of sObjects
     *
     * @param sobjects List of sObjects to take the value from
     */ 
	private RandomValue getRandomSObject(List<sObject> sobjects){
		//Declare list for Double Values for random Integers
		List<Double> ranks = new List<Double>();
		//Declare a Map for matching random integer with wrapper class
		Map<Double,RandomValue> rankMap = new Map<Double,RandomValue>();
		
		//Loop the list, keeping the index
		Integer i = 0;
		for(sObject so  : sobjects){
			//Get random values if they haven't been gotten before
			Boolean isDup = true;
			Double rank;
			While(isDup){
				Double x = getRandomInteger(maxInt);
				if(!rankMap.containsKey(x)){
					rank = x;
					isDup = false;
				}
			}
			//Add value to the list
			ranks.add(rank);
			
			//Generate wrapper instance
			RandomValue rand = new RandomValue(i,so);
			//Put wrapper instance in the map using the random key
			rankMap.put(rank,rand);
			i++;
		}
		
		//Sort random values and get the wrapper that correspond to the first key.
		ranks.sort();
		return rankMap.get(ranks.get(0));
	}
	
	/*
	 * Wrapper class of a sObject to take randomly from a list, with it's index from th elist
	 */
	private class RandomValue {
		Integer index {get;set;}
		sObject value {get;set;}
		
		//CONSTRUCTOR
		RandomValue (Integer i, sObject so) {
			index = i;
			value = so;
		}
	}
}