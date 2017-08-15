public class OpportunityStageUpdateJob implements Queueable {

    public Set<Id> AuctionIds{get;set;}
    public OpportunityStageUpdateJob(Set<Id> AuctionIds) {
        this.AuctionIds = AuctionIds;
    }

    public void execute(QueueableContext context) 
    {
        List<Opportunity> sObjList = new List<Opportunity>([SELECT Id,StageName, Auction_Opportunity_Assignment__c, 
                                                                   Most_Recent_Auction__r.Test_Event__c,
                                                                   Auction_Opportunity_Assignment__r.Status__c,
                                                                   Auction_Date_Today__c   
                                                            FROM Opportunity 
                                                            WHERE 
                                                            Most_Recent_Auction__c IN: AuctionIds AND
                                                            RecordTypeId = '012d0000000t0iC' AND  
                                                            (StageName = :Label.Opportunity_Stage2 OR StageName = :Label.Opportunity_Stage3 OR StageName = :Label.Opportunity_Stage4)
                                                           ]);
        system.debug('sObject List => ' +sObjList);        
        for(Opportunity s : sObjList) 
        {
            if(s.Auction_Opportunity_Assignment__r.Status__c == 'Auction' && s.StageName == Label.Opportunity_Stage4
               && s.Most_Recent_Auction__r.Test_Event__c == FALSE
               && s.Auction_Date_Today__c) 
            {
                system.debug('Stage 5 Update => ' +s);        
                s.StageName = Label.Opportunity_Stage5;
            }           
        /*    else if(s.Auction_Opportunity_Assignment__r.Status__c ==    'Auction'
                    && s.Most_Recent_Auction__r.Test_Event__c     ==     FALSE
                    && s.StageName                               ==     Label.Opportunity_Stage3) 
            {
                system.debug('Stage 4 Update => ' +s);
                s.StageName = Label.Opportunity_Stage4;
            }  */
        }

        try 
        {
            Update sObjList;
        } catch(exception e) 
        {
            system.debug('Exception = > ' +e); 
        }
    }
}