/**
 * Test Utilities class for common test methods and data creation
 */
@isTest
public with sharing class TestUtilities {
    
    //Control properties
    private static final Integer maxChars = 15;
    public static final Integer numberOfTakers = 10;
    public static final Integer numberOfAccounts = 1;
    public static final Integer numberOfTestForms = 1;
    public static final Integer numberOfExaminations = 2;
    public static final Integer numberOfQuestions = 30;
    public static final Integer numberOfAnswers = 5;
    public static final Integer numberOfCorrectAnswers = 2;
    public static final String draftStatus = 'Draft';
    
    //Get Random strings to avoid conflicts
    public static String getRandomString(Integer max) {
        String randomString = EncodingUtil.base64Encode(crypto.generateAesKey(128)).substring(1,max).toUpperCase();
        return randomString;
    }
    
    //Create a list of accounts
    public static List<Account> createAccounts(Integer quantity) {
        
        List<Account> returnAccounts = new List<Account>();
        Account tempAccount = new Account();
        for (Integer i = 0;i< quantity; i++) {
            tempAccount = new Account(name=getRandomString(maxChars));
            returnAccounts.add(tempAccount);
        }
        return returnAccounts;
    }
    
    //Create a list of test forms
    public static List<Test_Form__c> createTestForms(Integer quantity, Id AccountId, String Status) {
        
        List<Test_Form__c> returnTestForms = new List<Test_Form__c>();
        Test_Form__c tempTestForm = new Test_Form__c();
        for (Integer i = 0;i< quantity; i++) {
            tempTestForm = new Test_Form__c(name=getRandomString(maxChars), Account__c = AccountId, Test_Status__c = Status);
            returnTestForms.add(tempTestForm);
        }
        return returnTestForms;
    }
    
    //Create a list of examinations
    public static List<Examination__c> createExaminations(Integer quantity, Id TestFormId, Id TakerId, String Status) {
        
        List<Examination__c> returnExaminations = new List<Examination__c>();
        Examination__c tempExamination = new Examination__c();
        for (Integer i = 0;i< quantity; i++) {
            tempExamination = new Examination__c(name=getRandomString(maxChars), Test_Form__c = TestFormId, Examination_Status__c = Status, Examination_Taker__c = TakerId);
            returnExaminations.add(tempExamination);
        }
        return returnExaminations;
    }
    
    //Create a list of questions
    public static List<Question__c> createQuestions(Integer Quantity, Id parentId, Boolean isTestForm) {
        List<Question__c> returnQuestions = new List<Question__c>();
        Question__c tempQuestion = new Question__c();
        for (Integer i = 0;i< quantity; i++) {
            if (isTestForm) {
                tempQuestion = new Question__c(name=getRandomString(maxChars), Test_Form__c = parentId, Question_Number__c = i+1, Question__c = getRandomString(maxChars));
            }
            else {
                tempQuestion = new Question__c(name=getRandomString(maxChars), Examination__c = parentId, Question_Number__c = i+1, Question__c = getRandomString(maxChars));
            }
            returnQuestions.add(tempQuestion);
        }
        
        return returnQuestions;
    }
    
    //Create a list of answers
    public static List<Answer__c> createAnswers(Integer Quantity, Id QuestionId) {
        List<Answer__c> returnAnswers = new List<Answer__c>();
        Answer__c tempAnswer = new Answer__c();
        for (Integer i = 0;i< quantity; i++) {
            tempAnswer = new Answer__c(name=getRandomString(maxChars), Question__c = QuestionId, Number__c = i+1, Answer__c = getRandomString(maxChars));
            returnAnswers.add(tempAnswer);
        }
        
        return returnAnswers;
    }
    
    //Create a list of Exam Administrators
    public static List<User> getExamAdminUsers(Integer quantity) {
        List<User> returnUsers = new List<User>();
        Map<String,ID> profiles = new Map<String,String>();
        List<Profile> ps = [select id, name from Profile where name = 'Custom: Exam Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        User admin = new User();
        
        for (Integer i = 0;i< quantity; i++) {
            admin = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName=getRandomString(maxChars), LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = profiles.get('Custom: Exam Administrator'), 
                TimeZoneSidKey='America/Los_Angeles', UserName=getRandomString(maxChars) + '@cert501.ivan');
            returnUsers.add(admin);
        }
        
        return returnUsers;
    }
    
    //Create a list of Exam Takers
    public static List<User> getExamTakerUsers(Integer quantity) {
        List<User> returnUsers = new List<User>();
        Map<String,ID> profiles = new Map<String,String>();
        List<Profile> ps = [select id, name from Profile where name = 'Custom: Exam Taker'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        User taker = new User();
        
        for (Integer i = 0;i< quantity; i++) {
            taker = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName=getRandomString(maxChars), LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = profiles.get('Custom: Exam Taker'), 
                TimeZoneSidKey='America/Los_Angeles', UserName=getRandomString(maxChars) + '@cert501.ivan');
            returnUsers.add(taker);
        }
        return returnUsers;
    }
    
    //Create a list of exam takers with a specific account Id
    public static List<User> getExamTakerUsers(Integer quantity, String AccountId) {
        List<User> returnUsers = new List<User>();
        Map<String,ID> profiles = new Map<String,String>();
        List<Profile> ps = [select id, name from Profile where name = 'Custom: Exam Taker'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        User taker = new User();
        
        for (Integer i = 0;i< quantity; i++) {
            taker = new User(Account_ID__c = AccountId,Alias = 'standt', Email='standarduser@testorg.com', 
                EmailEncodingKey='UTF-8', LastName=getRandomString(maxChars), LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = profiles.get('Custom: Exam Taker'), 
                TimeZoneSidKey='America/Los_Angeles', UserName=getRandomString(maxChars) + '@cert501.ivan');
            returnUsers.add(taker);
        }
        return returnUsers;
    }
    
    //Create a set of bulk data for testing the User Loads
    public static List<User> createBulkData (String fakeAccount) {
        Integer numAcct = TestUtilities.numberOfAccounts;
        Integer numTests = TestUtilities.numberOfTestForms;
        Integer numUsers = TestUtilities.numberOfTakers;

        List<Account> accounts = TestUtilities.createAccounts(numAcct);
        insert accounts;
        List<Test_Form__c> testForms = new List<Test_Form__c>();
        List<Question__c> questions = new List<Question__c>();
        List<User> users = new List<User>();
        
        for (Account acc : accounts) {
            testForms.addAll(TestUtilities.createTestForms(numTests, acc.Id, 'Open'));
            if (fakeAccount == null)
                users.addAll(getExamTakerUsers(numUsers,acc.Id));
            else
                users.addAll(getExamTakerUsers(numUsers,fakeAccount));
        }
        
        insert testForms;
        
        for(Test_Form__c form : testForms) {
            //questions = new List<Question__c>();
            questions.addAll(TestUtilities.createQuestions(TestUtilities.numberOfQuestions, form.Id, true));
        }
        
        insert questions;
        
        List<Answer__c> answers = new List<Answer__c>();
        List<Answer__c> tempAnswers = new List<Answer__c>();
        Integer numberSelected = TestUtilities.numberOfCorrectAnswers;
        
        for (Question__c question : questions) {
            tempAnswers = TestUtilities.createAnswers(TestUtilities.numberOfAnswers, question.Id);
            for (Integer i = 0; i<tempAnswers.size(); i++) {
                if (i < numberSelected) {
                    tempAnswers[i].Selected__c = true;
                    tempAnswers[i].Correct__c = true;
                }
            }
            answers.addAll(tempAnswers);
        }
        insert answers;
        
        return users;
    }
    
    //Create a Question Wrapper for a correct question
    public static QuestionAnswerWrapper createCorrectQuestion() {
        List<Account> accounts = TestUtilities.createAccounts(1);
        insert accounts;
        List<Test_Form__c> testForms = TestUtilities.createTestForms(1, accounts[0].Id, 'Draft');
        insert testforms;
        List<Question__c> questions = TestUtilities.createQuestions(1, testforms[0].Id, true);
        insert questions;
        
        List<Answer__c> answers = new List<Answer__c>();
        List<Answer__c> tempAnswers = new List<Answer__c>();
        Integer numberSelected = TestUtilities.numberOfCorrectAnswers; 
        for (Question__c question : questions) {
            tempAnswers = TestUtilities.createAnswers(TestUtilities.numberOfAnswers, question.Id);
            for (Integer i = 0; i<tempAnswers.size(); i++) {
                if (i < numberSelected) {
                    tempAnswers[i].Selected__c = true;
                    tempAnswers[i].Correct__c = true;
                }
            }
            answers.addAll(tempAnswers);
        }
        insert answers;
        
        questions[0] = [Select 
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
                     where Id = :questions[0].Id limit 1];
        return new QuestionAnswerWrapper(questions[0]);
    }
    
    //Create a Question Wrapper for a wrong question
    public static QuestionAnswerWrapper createWrongQuestion() {
        List<Account> accounts = TestUtilities.createAccounts(1);
        insert accounts;
        List<Test_Form__c> testForms = TestUtilities.createTestForms(1, accounts[0].Id, 'Draft');
        insert testforms;
        List<Question__c> questions = TestUtilities.createQuestions(1, testforms[0].Id, true);
        insert questions;
        
        List<Answer__c> answers = new List<Answer__c>();
        List<Answer__c> tempAnswers = new List<Answer__c>();
        Integer numberSelected = TestUtilities.numberOfCorrectAnswers; 
        for (Question__c question : questions) {
            tempAnswers = TestUtilities.createAnswers(TestUtilities.numberOfAnswers, question.Id);
            for (Integer i = 0; i<tempAnswers.size(); i++) {
                if (i < numberSelected) {
                    tempAnswers[i].Selected__c = false;
                    tempAnswers[i].Correct__c = true;
                }
                else
                    tempAnswers[i].Selected__c = true;
            }
            answers.addAll(tempAnswers);
        }
        insert answers;
        
        questions[0] = [Select 
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
                     where Id = :questions[0].Id limit 1];
                                     
        return new QuestionAnswerWrapper(questions[0]);
    }
    
    //Create an individual examination that has been passed or not, depending on the parameter
    public static Examination__c createExamination(User taker, Boolean passed) {
        List<Account> accounts = TestUtilities.createAccounts(1);
        insert accounts;
        List<Test_Form__c> testForms = TestUtilities.createTestForms(1, accounts[0].Id, 'Draft');
        insert testforms;
        List<Examination__c> examinations = TestUtilities.createExaminations(1, testForms[0].Id, taker.Id, 'In Progress');
        insert examinations;
        List<Question__c> questions = TestUtilities.createQuestions(TestUtilities.numberOfQuestions, examinations[0].Id, false);
        insert questions;
        
        List<Answer__c> answers = new List<Answer__c>();
        List<Answer__c> tempAnswers = new List<Answer__c>();
        Integer numberSelected = TestUtilities.numberOfCorrectAnswers; 
        for (Question__c question : questions) {
            tempAnswers = TestUtilities.createAnswers(TestUtilities.numberOfAnswers, question.Id);
            for (Integer i = 0; i<tempAnswers.size(); i++) {
                if (passed) {
                    if (i < numberSelected) {
                        tempAnswers[i].Selected__c = true;
                        tempAnswers[i].Correct__c = true;
                    }
                }
                else {
                    if (i < numberSelected) {
                        tempAnswers[i].Selected__c = false;
                        tempAnswers[i].Correct__c = true;
                    }
                    else
                        tempAnswers[i].Selected__c = true;
                }
            }
            answers.addAll(tempAnswers);
        }
        insert answers;
        
        return examinations[0];
    }
    
    //Create an individual Test Form that has been passed or not, depending on the parameter
    public static Test_Form__c createTestForm(Boolean passed) {
        List<Account> accounts = TestUtilities.createAccounts(1);
        insert accounts;
        List<Test_Form__c> testForms = TestUtilities.createTestForms(1, accounts[0].Id, 'Draft');
        insert testforms;
        List<Question__c> questions = TestUtilities.createQuestions(TestUtilities.numberOfQuestions, testForms[0].Id, true);
        insert questions;
        
        List<Answer__c> answers = new List<Answer__c>();
        List<Answer__c> tempAnswers = new List<Answer__c>();
        Integer numberSelected = TestUtilities.numberOfCorrectAnswers; 
        for (Question__c question : questions) {
            tempAnswers = TestUtilities.createAnswers(TestUtilities.numberOfAnswers, question.Id);
            for (Integer i = 0; i<tempAnswers.size(); i++) {
                if (passed) {
                    if (i < numberSelected) {
                        tempAnswers[i].Selected__c = true;
                        tempAnswers[i].Correct__c = true;
                    }
                }
                else {
                    if (i < numberSelected) {
                        tempAnswers[i].Selected__c = false;
                        tempAnswers[i].Correct__c = true;
                    }
                    else
                        tempAnswers[i].Selected__c = true;
                }
            }
            answers.addAll(tempAnswers);
        }
        insert answers;
        return testForms[0];
    }
}