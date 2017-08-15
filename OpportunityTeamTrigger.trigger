trigger OpportunityTeamTrigger on OpportunityTeamMember (before insert,before update, after insert) {   
          system.debug('Entering Trigger => ');
          Set<Id> OpptyIds = new Set<Id>();
          if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
              for(OpportunityTeamMember otm : Trigger.New) {
                  User UserDetails = UserUtil.getUser(otm.UserId);                    
                  if(UserDetails!=null) {
                      otm.Team_Member_Area__c = UserDetails.Area__c;
                  }
                  OpptyIds.add(otm.OpportunityId);
              }
          }
           
          if(Trigger.isInsert && Trigger.isAfter) {
              List<OpportunityTeamMember> CurrentTeamMemberList = new  List<OpportunityTeamMember>([SELECT Id,TeamMemberRole,OpportunityId,UserId FROM OpportunityTeamMember WHERE OpportunityId IN :Trigger.NewMap.KeySet()]); 
              Set<String> CurrentTeamMemberSet = new Set<String>();
              for(OpportunityTeamMember cotm : CurrentTeamMemberList) {
                  CurrentTeamMemberSet.add(String.valueof(cotm.OpportunityId)+ String.valueof(cotm.UserId));
              }
              
              system.debug('After Insert => ' +CurrentTeamMemberList); 
              List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
              for(OpportunityTeamMember otm : Trigger.New) {         
                  if(!CurrentTeamMemberSet.contains(String.valueof(otm.OpportunityId)+ String.valueof(otm.UserId))) {
                      User UserDetails = UserUtil.getUser(otm.UserId);
                      if(UserDetails!=null && otm.TeamMemberRole=='Opportunity Owner') {
                          if(UserDetails.ManagerId!=null) {
                              OpportunityTeamMember newotm = new OpportunityTeamMember();
                              newotm.OpportunityId = otm.OpportunityId;
                              newotm.UserId = UserDetails.ManagerId;
                              newotm.TeamMemberRole = Label.Opportunity_Owner_Manager_Role;
                              otmList.add(newotm); 
                              CurrentTeamMemberSet.add(String.Valueof(otm.OpportunityId)+String.Valueof(otm.UserId));
                          }
                      }
                  }                 
              }
              try {  
                  Insert otmList;
              } catch (dmlexception e) {
                  system.debug('DML Exception ' +e);
              }
              system.debug('Inserted Splits : ' +otmList);              
          }
			// get all of the team members' sharing records
			//List<OpportunityShare> shares = [SELECT Id, OpportunityAccessLevel,  
			//  								 RowCause FROM OpportunityShare where OpportunityId IN :OpptyIds 
			//  and RowCause = 'Team'];
			
			// set all team members access to read/write
			//for (OpportunityShare share : shares)  
			//  share.OpportunityAccessLevel = 'Edit';
			
			//update shares;          
  }