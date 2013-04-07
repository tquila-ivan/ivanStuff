public with sharing class ExaminationsController {
	
	public TestFormsAvailable forms {
		get {
			return new TestFormsAvailable();
		}
		set;
	}
	 
	public ExaminationsController () {
	}
	
	public PageReference createExamination() {
		return null;
	}
}