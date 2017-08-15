@istest
public class TestChat_SurveyWebFormController{
    Private Static testmethod void TestChat_SurveyWebFormController(){    
        chat_survey__c cs = new chat_survey__c();
        cs.Additional_Comments__c = 'All the best';
        cs.chat_details__c = 'Ria L';
        insert cs;
        
        ApexPages.currentPage().getParameters().put('chatDetails',cs.chat_details__c);
        ApexPages.StandardController stdcs = new ApexPages.StandardController(cs);
        Chat_SurveyWebFormController objMyChatsurveyController  = new Chat_SurveyWebFormController(stdcs);
        objMyChatsurveyController.submitChatSurvey();
      //  objMyChatsurveyController.Save();
       // objMyChatsurveyController.Back();
    }
}