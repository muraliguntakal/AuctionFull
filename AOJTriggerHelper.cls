public with sharing class AOJTriggerHelper {

//************************************************Create Asset**************************************************
public void Create_Assets(List<AssetOppJunction__c> newAOJlist, Map<Id,AssetOppJunction__c> OldInkas, Boolean isInsert, Boolean isUpdate) {
Set<string> uniqueIds = new Set<string>(); 
List<AssetOppJunction__c> AOJList = new List<AssetOppJunction__c>();
if(isInsert){
  for (AssetOppJunction__c newAOJ: newAOJlist) { 
        if(newAOJ.Unique_Asset_Field__c != null && newAOJ.Unique_Asset_Field__c != ' ' && newAOJ.Unique_Asset_Field__c != '' && newAOJ.Opportunity_RecordType_Id__c == Label.Parent_Opportunity) { 
            if(newAOJ.Property_Address__c !=null && newAOJ.Property_Zip__c!=null) { 
                uniqueIds.add(newAOJ.Unique_Asset_Field__c);
                 AOJList.add(newAOJ);
             }
         } 
     }
 }        
else if(isUpdate){
     for (AssetOppJunction__c newAOJ: newAOJlist) {
            if(newAOJ.Unique_Asset_Field__c != null && newAOJ.Unique_Asset_Field__c != ' ' && newAOJ.Unique_Asset_Field__c != '' && newAOJ.Opportunity_RecordType_Id__c == Label.Parent_Opportunity && 
               (newAOJ.Property_Address__c != OldInkas.get(newAOJ.Id).Property_Address__c || newAOJ.Property_Zip__c != OldInkas.get(newAOJ.Id).Property_Zip__c)) { 
            if(newAOJ.Property_Address__c !=null && newAOJ.Property_Zip__c!=null) { 
                uniqueIds.add(newAOJ.Unique_Asset_Field__c);
                AOJList.add(newAOJ);
             }
         } 
     } 
 } 
            List<asset__c> AssetList = New List<asset__c>(); 
            if(uniqueIds.size() > 0) {
                 AssetList = New List<Asset__c> ([SELECT Id,Asset_SF_Unique_ID__c,Property_Name__c,Property_Street__c,Property_City__c,Property_State__c,Property_Zip_Postal_Code__c,
                                                  Occupancy_Status__c,Home_Square_Footage__c,Bedrooms__c,Baths__c,Property_Type__c
                                                  FROM Asset__c 
                                                  WHERE Asset_SF_Unique_ID__c IN :uniqueIds AND Asset_SF_Unique_ID__c!=null AND Asset_SF_Unique_ID__c!=' ']);
            } 
       Map<String, Asset__c> AssetMap = new Map<String, Asset__c>();     
       if(!AssetList.isEmpty()){      
           for(Asset__c ast : AssetList) {
               if(ast.Asset_SF_Unique_ID__c!=null)
                   AssetMap.put(ast.Asset_SF_Unique_ID__c,ast);
            } 
        }     
//Creating Asset if not found 
    List<Asset__c> CreateAssets = new List<Asset__c>(); 
       for (AssetOppJunction__c newAOJS: AOJList) { 
          if(newAOJS.Unique_Asset_Field__c!=null) {
             if(!AssetMap.containsKey(newAOJS.Unique_Asset_Field__c)) {
                 Asset__c ast = new Asset__c(AssetOppJunction__c = newAOJS.Id, Property_Name__c = newAOJS.Property_Name__c, Property_Type__c = newAOJS.Property_Type__c, Property_Street__c = newAOJS.Property_Address__c, 
                                             Property_City__c = newAOJS.Property_City__c, Property_State__c = newAOJS.Property_State__c, Property_Zip_Postal_Code__c = newAOJS.Property_Zip__c); 
                                             CreateAssets.add(ast);
                                             AssetMap.put(newAOJS.Unique_Asset_Field__c,ast); 
              } 
           } 
         }     
          if(!CreateAssets.isEmpty()){ 
              Insert CreateAssets;
           } 
     if(!AssetMap.isEmpty()){
           for (AssetOppJunction__c newAOJS: AOJList) { 
               newAOJS.Asset_del__c= AssetMap.get(newAOJS.Unique_Asset_Field__c).Id; 
           } 
      }  
}


//*******************************Create Valuation********************************************************** 
public void Create_Valuation(List<AssetOppJunction__c> AOJlistRecords) {

List<Valuation__c> createValuations = new List <Valuation__c>(); 
for (AssetOppJunction__c newAOJs: AOJlistRecords) { 
if(newAOJs.Opportunity_RecordType_Id__c == Label.Commercial_Opportunity_Rectype_Id || newAOJs.Opportunity_RecordType_Id__c == Label.Parent_Opportunity) {
if(newAOJs.Opportunity__c != null && newAOJs.Asset_del__c != null) { 
createValuations.add(new Valuation__c(AssetOppJunction__c = newAOJs.Id, Opportunity__c = newAOJs.Opportunity__c, Asset__c=newAOJs.Asset_del__c,Value_REDC_Date__c=newAOJs.Value_REDC_Date__c,Value_Seller_Date__c=newAOJs.Value_Seller_Date__c,
Value_REDC_High__c = newAOJs.Value_REDC_High__c,Value_REDC_Low__c = newAOJs.Value_REDC_Low__c,Value_REDC_Mod__c = newAOJs.Value_REDC_Mod__c,
Value_Seller_High__c = newAOJs.Value_Seller_High__c,Value_Seller_Low__c = newAOJs.Value_Seller_Low__c,Value_Seller_Mod__c=newAOJs.Value_Seller_Mod__c)); 
}
} 
} 
if(!createValuations.isEmpty())
Insert createValuations; 
}


/*
//************************************Create VRO after Docusign is completed********************************
public void Create_VRO(Map<Id,AssetOppJunction__c> NewMapAOJ, Map<Id,AssetOppJunction__c> OldMapAOJ) {

Map<Id, AssetOppJunction__c> AOJMap = new Map<Id, AssetOppJunction__c>(); 

for (AssetOppJunction__c AOJnew: NewMapAOJ.Values()) { 
if(AOJnew.ADC_Intake_Memo_Status__c != OldMapAOJ.get(AOJnew.Id).ADC_Intake_Memo_Status__c && AOJnew.ADC_Intake_Memo_Status__c == 'Completed')
{
AOJMap.put(AOJnew.Id, AOJnew); 
}
}

List<Valuation__c> ValList = new List<Valuation__c>(); 
ValList = [Select Id,Value_REDC_High__c,Value_REDC_Low__c from Valuation__c where AssetOppJunction__c IN:AOJMap.KeySet()]; 

List<BPO__c> vrolist = new List <BPO__c>(); 
if(!ValList.isEmpty()){ 
for(Valuation__c val: ValList)
{
vrolist.add(new BPO__c(Valuation__c = val.Id,Valuation_Id__c = val.Id,RecordTypeId = Label.VRO_Internal_Apprisal, High_Range__c = val.Value_REDC_High__c, Low_Range__c = val.Value_REDC_Low__c,Valuation_Date__c= system.today())); 
}
} 

if(!vrolist.isEmpty())
Insert vrolist; 
}  */


//************************************Update PhotoOrder if Operations Manager is changed********************************
public void UpdatePhotoOrder(Map<Id,AssetOppJunction__c> NewMapAOJ, Map<Id,AssetOppJunction__c> OldMapAOJ) {

Map<Id, AssetOppJunction__c> AOJMap = new Map<Id, AssetOppJunction__c>(); 

for (AssetOppJunction__c AOJnew: NewMapAOJ.Values()) { 
    if(AOJnew.Transaction_Manager__c != OldMapAOJ.get(AOJnew.Id).Transaction_Manager__c)
    {
        AOJMap.put(AOJnew.Id, AOJnew); 
    }
}

Map<ID, BPO__c> PhotoMap = new Map<ID, BPO__c>();
PhotoMap = new Map<Id, BPO__c>([Select Id,Transaction_Manager__c,Property_Intake_Submission_Forms__c from BPO__c where Property_Intake_Submission_Forms__c IN:AOJMap.KeySet()]); 

List<BPO__c> UpdatePhoto = new List <BPO__c>(); 
if(!PhotoMap.isEmpty()){ 
    for(BPO__c phot: PhotoMap.Values())
    {
         if(AOJMap.ContainsKey(phot.Property_Intake_Submission_Forms__c)){
            phot.Transaction_Manager__c = AOJMap.get(phot.Property_Intake_Submission_Forms__c).Transaction_Manager__c;
            UpdatePhoto.add(phot);
          }  
    } 
}

if(!UpdatePhoto.isEmpty())
Update UpdatePhoto; 
}


//************************************Update Parent Opportunity after Valuation Request Status is completed******************************** 

public void UpdateParentOppStage(Map<Id,AssetOppJunction__c> NewAOJ, Map<Id,AssetOppJunction__c> OldAOJ) {
List<AssetOppJunction__c> IntakeLists = new List<AssetOppJunction__c>(); 
Set<Id> OppSetId = new Set<Id>(); 
for (AssetOppJunction__c newProp: NewAOJ.Values()) { 
    if(newProp.Opportunity_Stage__c == 'Stage 2: Pitch' && newProp.Auction_Approval_Status__c != null && newProp.Auction_Approval_Status__c != OldAOJ.get(newProp.Id).Auction_Approval_Status__c){
        OppSetId.add(newProp.Opportunity__c); 
    }
}

Map<ID, Opportunity> ParentOppMap = new Map<ID, Opportunity>();
ParentOppMap = new Map<Id, Opportunity>([Select Id,StageName,Status__c from Opportunity where Id IN: OppSetId]);

for (AssetOppJunction__c newProp: NewAOJ.Values()) {
if(newProp.Opportunity_Stage__c == 'Stage 2: Pitch' && newProp.Auction_Approval_Status__c != null && newProp.Auction_Approval_Status__c != OldAOJ.get(newProp.Id).Auction_Approval_Status__c){
    Opportunity parentopp = ParentOppMap.get(newProp.Opportunity__c);
       if(newProp.Auction_Approval_Status__c == 'Submitted'){
          parentopp.Status__c = 'C - Currently being approved for platform';
        }
        else if (newProp.Auction_Approval_Status__c == 'Approved'){
          parentopp.Status__c = 'D - Approved for Platform, not submitted for Go-Live';
        }
        else if (newProp.Auction_Approval_Status__c == 'Rejected'){
          parentopp.Status__c = 'X - Rejected for Platform, not submitted for Go-Live';
        } 
      }        
    }
 
    if(!ParentOppMap.isEmpty()){ 
        Update ParentOppMap.values();
    } 
}


/*
//************************************Update Parent Opportunity after Valuation Request Status is Pending DD Approval******************************** 

public void UpdateParentOppSubmitted(Map<Id,AssetOppJunction__c> NewAOJs, Map<Id,AssetOppJunction__c> OldAOJs) {

Set<Id> OppsSetId = new Set<Id>(); 

for (AssetOppJunction__c newProps: NewAOJs.Values()) { 
if(newProps.Valuation_Request_Status__c != OldAOJs.get(newProps.Id).Valuation_Request_Status__c && newProps.Valuation_Request_Status__c == 'Pending DD Approval')
{
OppsSetId.add(newProps.Opportunity__c); 
}
}

List<AssetOppJunction__c> AOJRelatedtoOpps = new List<AssetOppJunction__c>(); 
AOJRelatedtoOpps = [SELECT Id FROM AssetOppJunction__c WHERE Opportunity__c IN: OppsSetId AND Valuation_Request_Status__c != 'Pending DD Approval']; 

if(AOJRelatedtoOpps.isEmpty()){

List<Opportunity> ParentOppLists = new List<Opportunity>(); 
ParentOppLists = [Select Id,Fast_Pass_Account__c from Opportunity where Id IN: OppsSetId];

List<Opportunity> UpdateParentOpps = new List<Opportunity>(); 

        if(!ParentOppLists.isEmpty()){
            for(Opportunity parentopps: ParentOppLists){
                 if(parentopps.Fast_Pass_Account__c == True){ 
                        parentopps.StageName = Label.Opportunity_Stage2;
                        parentopps.Status__c = 'D. Waiting to discuss valuation with client (2-3 days)';
                  }
                  else {
                        parentopps.StageName = Label.Opportunity_Stage2;
                        parentopps.Status__c = 'Valuation Initiated';                 
                  }
                  UpdateParentOpps.add(parentopps);
             }    
        } 

if(!UpdateParentOpps.isEmpty()){ 
Update UpdateParentOpps;
} 
}
}
*/

//************************************Auto populate Listing Broker********************************  
      
   public void AutopopulateListingBroker(List<AssetOppJunction__c> NewInksList, Map<Id,AssetOppJunction__c> NewInks, Map<Id,AssetOppJunction__c> OldInks, Boolean isInsert, Boolean isUpdate) { 
                    
   if(isInsert){    
         for (AssetOppJunction__c newIntake: NewInksList) {  
            if (newIntake.Property_State__c != null){
                 String StageUpper = newIntake.Property_State__c.touppercase();
               if(Legal_Broker_Contact_Ids__c.getValues(StageUpper) != null){
                   newIntake.Agency_Disclosure__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Agency_Disclosure__c;
                   newIntake.Supervising_Broker__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Supervising_Broker__c;                  
                }               
              }                 
           } 
        }                
                
                  
       if(isUpdate){          
         for (AssetOppJunction__c newIntake: NewInks.Values()) {
             if (newIntake.Property_State__c != null){  
                  String StageUpper = newIntake.Property_State__c.touppercase();                                            
               if (newIntake.Property_State__c != OldInks.get(newIntake.Id).Property_State__c){
                  if(Legal_Broker_Contact_Ids__c.getValues(StageUpper) != null){               
                    newIntake.Agency_Disclosure__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Agency_Disclosure__c;                 
                    newIntake.Supervising_Broker__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Supervising_Broker__c;
                   }            
                 }                   
 
            //PSA Forms attachment Automation                       
               if (newIntake.Property_State__c != OldInks.get(newIntake.Id).Property_State__c || newIntake.ADC_Form__c != OldInks.get(newIntake.Id).ADC_Form__c || newIntake.ADC_s_Form_with_Seller_s_Addendum__c != OldInks.get(newIntake.Id).ADC_s_Form_with_Seller_s_Addendum__c || 
                   newIntake.Seller_s_own_with_ADC_s_Addendum__c != OldInks.get(newIntake.Id).Seller_s_own_with_ADC_s_Addendum__c || newIntake.If_using_ADC_s_PA_check_all_that_apply__c != OldInks.get(newIntake.Id).If_using_ADC_s_PA_check_all_that_apply__c || 
                   newIntake.Legal_Team_Status__c != OldInks.get(newIntake.Id).Legal_Team_Status__c){
                 
                  if(Legal_Broker_Contact_Ids__c.getValues(StageUpper) != null && (newIntake.ADC_Form__c == True ||  newIntake.ADC_s_Form_with_Seller_s_Addendum__c== True) && newIntake.Legal_Team_Status__c == 'Approved'){
                  
                    newIntake.PMA_Conga_Template_Id__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).PSA_Conga_Template_Id__c; 
                    newIntake.PSA_ADC_CongaTemplateId__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Purchase_Agreement_06082015__c; 
                    
                                 if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c != null){
                                 if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Hotel and Personal Property')){
                                      newIntake.Property_is_a_hotel_motel__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Hotel_and_Personal_05192015__c; 
                                  }
                                 else {
                                      newIntake.Property_is_a_hotel_motel__c= null; 
                                      }
                                 if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Custom Seller Addendum')){
                                      newIntake.Seller_modifying_with_own_Addendum__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Seller_modifying_with_own_Addendum__c; 
                                  }
                                  else {
                                      newIntake.Seller_modifying_with_own_Addendum__c= null; 
                                      }
                                 if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Personal Property Only')){
                                      newIntake.Personal_property_will_be_conveyed__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Personal_property_will_be_conveyed__c; 
                                  }
                                  else {
                                      newIntake.Personal_property_will_be_conveyed__c= null; 
                                      }
                                 if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('General Financing Contingency') || newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Franchise Agreement')){
                                      newIntake.Financing_contingency__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Financing_contingency__c; 
                                  }
                                  else {
                                      newIntake.Financing_contingency__c= null; 
                                      }
                                 if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Leasehold Conveyance')){
                                      newIntake.Property_is_a_leasehold_interest__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Property_is_a_leasehold_interest__c; 
                                  }
                                  else {
                                      newIntake.Property_is_a_leasehold_interest__c= null; 
                                      }
                                 if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Land Sale')){
                                      newIntake.Property_is_land_only__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Property_is_land_only__c; 
                                  }
                                  else {
                                      newIntake.Property_is_land_only__c= null; 
                                      }
                                 if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Buyer Loan Assumption')){
                                      newIntake.Loan_assumed_must_pay_loan_fee__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Loan_assumed_must_pay_loan_fee__c; 
                                  }
                                  else {
                                      newIntake.Loan_assumed_must_pay_loan_fee__c= null; 
                                      }
                                  if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Subject To Sale')){
                                      newIntake.Property_will_be_sold_subject_to_seller__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Property_will_be_sold_subject_to_seller__c; 
                                  }
                                  else {
                                      newIntake.Property_will_be_sold_subject_to_seller__c= null; 
                                      }
                                  if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('1031 Tax Exchange Sale')){
                                      newIntake.Property_is_subject_to_1031_Tax_Exchan__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Property_is_subject_to_a_1031_Tax_Exchan__c; 
                                  }
                                  else {
                                      newIntake.Property_is_subject_to_1031_Tax_Exchan__c= null; 
                                      }
                                  if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Extension To Closing')){
                                      newIntake.Extension_Option__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Extension_Option__c; 
                                  }
                                  else {
                                      newIntake.Extension_Option__c= null; 
                                      }
                                  if(newIntake.If_using_ADC_s_PA_check_all_that_apply__c.contains('Closing Cost Modifications')){
                                      newIntake.Closing_Cost_Allocation__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Closing_Cost_Allocation__c; 
                                  }
                                  else {
                                      newIntake.Closing_Cost_Allocation__c= null; 
                                      }
                           }    
                           else
                                {
                                        newIntake.Property_is_a_hotel_motel__c= null;
                                        newIntake.Seller_modifying_with_own_Addendum__c= null;
                                        newIntake.Personal_property_will_be_conveyed__c= null; 
                                        newIntake.Financing_contingency__c= null;  
                                        newIntake.Property_is_a_leasehold_interest__c= null; 
                                        newIntake.Property_is_land_only__c= null; 
                                        newIntake.Loan_assumed_must_pay_loan_fee__c= null; 
                                        newIntake.Property_will_be_sold_subject_to_seller__c= null; 
                                        newIntake.Property_is_subject_to_1031_Tax_Exchan__c= null; 
                                        newIntake.Closing_Cost_Allocation__c= null; 
                                        newIntake.Extension_Option__c= null; 
                               }  
                      
                   }   
                  else if(Legal_Broker_Contact_Ids__c.getValues(StageUpper) != null && newIntake.Seller_s_own_with_ADC_s_Addendum__c== True && newIntake.Legal_Team_Status__c == 'Approved'){
                    newIntake.PMA_Conga_Template_Id__c= null; 
                    newIntake.PSA_ADC_CongaTemplateId__c=Legal_Broker_Contact_Ids__c.getValues(StageUpper).Seller_Form_Purchase_Agreement_06082015__c; 
                    newIntake.Property_is_a_hotel_motel__c= null;
                    newIntake.Seller_modifying_with_own_Addendum__c= null;
                    newIntake.Personal_property_will_be_conveyed__c= null; 
                    newIntake.Financing_contingency__c= null;  
                    newIntake.Property_is_a_leasehold_interest__c= null; 
                    newIntake.Property_is_land_only__c= null; 
                    newIntake.Loan_assumed_must_pay_loan_fee__c= null; 
                    newIntake.Property_will_be_sold_subject_to_seller__c= null; 
                    newIntake.Property_is_subject_to_1031_Tax_Exchan__c= null; 
                    newIntake.Closing_Cost_Allocation__c= null; 
                    newIntake.Extension_Option__c= null; 
                   }             
              }  
           }
          }               
        }    
                                     
   }


}