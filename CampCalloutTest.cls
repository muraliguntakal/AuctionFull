@isTest(SeeAllData=True)
public class CampCalloutTest {
     public static testMethod void CampWebServiceCallout()
     {       
       List<AssetOppJunction__c> intakes = [select Id from AssetOppJunction__c where Test_Camp_Asset__c = True limit 1];
       set<Id> intakesId = new set<Id>();
           for(AssetOppJunction__c aojs: intakes){
                 intakesId.add(aojs.Id);
             }
                          
      Test.StartTest();  
      CampMockTestUtil.RestOrderManagerMockTests();
      CampWebServiceCallout.sendNotification(intakesId);
      Test.StopTest();           
    }
}