public with sharing class TestFormsAvailable {
	
	public List<TestFormAvailable> testFormsAvailable {get;set;}
	
	private static final String adminProfileName = 'Custom: Exam Administrator';
	private static final String takerProfileName = 'Custom: Exam Taker';
	private static final String draftStatusString = 'Draft';
	private static final String openStatusString = 'Open';
	
	public TestFormsAvailable () {
		
		testFormsAvailable = new List<TestFormAvailable>();

		fillAvailableForms(Userinfo.getUserId());
	}
	
	private void fillAvailableForms (Id userId) {
		
		
		List<Test_Form__c> userTestForms = new List<Test_Form__c>();
		userTestForms = [Select Name from Test_Form__c where Test_Status__c = :draftStatusString];

		/*
		User userProfile = [Select Profile.Name, Account_Id__c from User where Id = :userId limit 1];
		
		if (userProfile.Profile.Name == adminProfileName) {
			userTestForms = [Select Name from Test_Form__c where Test_Status__c = :draftStatusString];
		}
		
		if (userProfile.Profile.Name == takerProfileName) {
			userTestForms = [Select Id,Name from Test_Form__c where Account__c = :userProfile.Account_Id__c and Test_Status__c = :openStatusString];
		}
		*/
		
		Map<Id,Test_Form__c> testFormsMap = getFormsMap(userTestForms);
		
		List<Examination__c> userExaminations = [Select Name,Test_Form__c from Examination__c where Test_Form__c in :testFormsMap.keyset() and Examination_Taker__c = :userId];
		
		TestFormAvailable testAvailable = new TestFormAvailable();
		
		for (Examination__c exam : userExaminations) {
			testAvailable = new TestFormAvailable();
			testAvailable.examinationCreated = true;
			testAvailable.testForm = testFormsMap.get(exam.Test_Form__c);
			testFormsAvailable.add(testAvailable);
			testFormsMap.remove(exam.Test_Form__c);
		}
		
		for (Id key : testFormsMap.keyset()) {
			testAvailable = new TestFormAvailable();
			testAvailable.examinationCreated = false;
			testAvailable.testForm = testFormsMap.get(key);
			testFormsAvailable.add(testAvailable);
		}
	}
	
	private Map<Id,Test_Form__c> getFormsMap(List<Test_Form__c> forms) {
		Map<Id,Test_Form__c> testFormsMap = new Map<Id,Test_Form__c>();
		for (Test_Form__c testForm : forms) {
				testFormsMap.put(testForm.Id, testForm);
		}
		
		return testFormsMap;
	}

	public class TestFormAvailable {
		public Test_Form__c testForm {get;set;}
		public Boolean examinationCreated {get;set;} 
	}
}