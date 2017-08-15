trigger AssignSurveyOwner on Chat_Survey__c (before insert) { 
   for (Chat_Survey__c ld : Trigger.new) {
   
         if(ld.Chat_Details__c.contains('Ria L') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = '005d0000002AyAV'; 
         }
        else if(ld.Chat_Details__c.contains('Ashley R') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Ashley_Robels; 
         }
        else if(ld.Chat_Details__c.contains('Briana H') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Briana_Herzog; 
         }
        else if(ld.Chat_Details__c.contains('Christy H') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Christy_Humphrey; 
         }
         else if(ld.Chat_Details__c.contains('Jason J') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Jason_Johnson; 
         }
        else if(ld.Chat_Details__c.contains('Jay F') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Jay_Fox; 
         }
        else if(ld.Chat_Details__c.contains('Jessie D') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Jessie_Duarte; 
         }
       else if(ld.Chat_Details__c.contains('Jill G') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Jill_Glatt; 
         }
        else if(ld.Chat_Details__c.contains('Joel G') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Joel_Garcia; 
         }
      else if(ld.Chat_Details__c.contains('Lu F') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Lu_Filivaa; 
         }
        else if(ld.Chat_Details__c.contains('Monique M') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Monique_Melendez; 
         }  
          else if(ld.Chat_Details__c.contains('Phil L') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Phil_Laveau; 
         } 
          else if(ld.Chat_Details__c.contains('Richard N') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Richard_Nutt; 
         } 
          else if(ld.Chat_Details__c.contains('Shawn K') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Shawn_Kloth; 
         } 
          else if(ld.Chat_Details__c.contains('Stephanie C') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Stephanie_Castro; 
         } 
          else if(ld.Chat_Details__c.contains('Tina R') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Tina_Ruiz; 
         } 
          else if(ld.Chat_Details__c.contains('Vicky H') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Vicky_Hernandez; 
         } 
          else if(ld.Chat_Details__c.contains('Wolfgang H') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Wolfgang_Hamann; 
         } 
          else if(ld.Chat_Details__c.contains('Yamir G') && ld.Chat_Details__c != null && ld.Chat_Details__c != ''){
             ld.Live_Agent__c = Label.CS_Yamir_Gonzalez; 
         }  
              
   }
}