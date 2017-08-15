public class ContactRelationshipController {
    // This class presents a list of contacts from the Contact Relationship table for inclusion on the Contact record.
    // Unlike a standard related list, it includes the contact one is viewing in the list,
    // and it consolidates the two related lists produced from a contact-contact junction table into a single list. 
    // Author: Erik Myklestad, Dec 2014.
    // 
    public list<RelationshipWrapper> relationshipWraps {get; set;}
    public boolean displayRelationships {get; set;}
    public string debug {get; set;}
    
    
    private id selectedContactId;
    
    public ContactRelationshipController(ApexPages.StandardController stdController){
       selectedContactId = ((Contact)stdController.getRecord()).id;
       createRelationshipWrapper();
    }
    
    public ContactRelationshipController(id contactId){
        // Alternate constructor for testing the page as a standalone page
        selectedContactId = contactId;
        createRelationshipWrapper();
    }
    
    private void createRelationshipWrapper(){
        list<Contact_Relationship__c> relationships = [select id, contact1__c, contact1__r.Name, relationship1__c, contact2__c, contact2__r.Name, relationship2__c from Contact_Relationship__c
                                                   where contact1__c = :selectedContactId or contact2__c = :selectedContactId ];
        relationshipWraps = new list<RelationshipWrapper>();
            
        for (Contact_Relationship__c cr : relationships){
            RelationshipWrapper wrapper = new RelationshipWrapper(selectedContactId, cr.id, cr.contact1__c, cr.contact1__r.Name, cr.relationship1__c, cr.contact2__c, cr.contact2__r.Name, cr.relationship2__c);
            relationshipWraps.add(wrapper);
        }
        if (relationshipWraps.isEmpty()) displayRelationships = false;
        else displayRelationships = true;
    }
    
    public PageReference newRelationship(){
        // Take them to the Contact Relationship table
        Schema.DescribeSObjectResult r = Contact_Relationship__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference pageRef = new PageReference('/' + keyPrefix + '/e?retURL=%2F' + selectedContactId);
        return pageRef;
    }
    
    public PageReference editRelationship(){
        // https://cs21.salesforce.com/a0Tq0000000FxMJ/e?retURL=%2Fa0Tq0000000FxMJ
        id relationshipId = System.currentPageReference().getParameters().get('crId');
        PageReference pageRef = new PageReference('/' + relationshipId + '/e?retURL=%2F' + selectedContactId);
        return pageRef;
    }
    
    public PageReference deleteRelationship(){
        id relationshipId = System.currentPageReference().getParameters().get('crId');
        Contact_Relationship__c cr = new Contact_Relationship__c(id = relationshipId);
        delete cr;
        return null;
    }
    
    public class RelationshipWrapper {
        // This wrapper takes data from the contact relationship record and swaps relationships so that the 
        // contact which matches the selected contact is always on the left side of the relationship; i.e. the selected contact is always contact1.
        public id contactId {get; set;}
        public string relationshipId {get; set;}
        public boolean reversed {get; set;}
        public id contact1_Id {get; set;}
        public string contact1_Name {get; set;}
        public string relationship1 {get; set;}
        public id contact2_Id {get; set;}
        public string contact2_Name {get; set;}
        public string relationship2 {get; set;}
        
        public RelationshipWrapper(id conId, string relationshipId, id contact1_Id, string name1, string relationship1, id contact2_Id, string name2, string relationship2){
            
            if (conId == contact1_Id){
                this.contactId = conId;
                this.relationshipId = relationshipId;
                this.reversed = false;
                this.contact1_Id = contact1_Id;
                this.contact1_Name = name1;
                this.relationship1 = relationship1;
                this.contact2_Id = contact2_Id;
                this.contact2_Name = name2;
                this.relationship2 = relationship2;
            }
            else{
                // Swap the relationship position between the two contacts
                this.contactId = conId;
                this.relationshipId = relationshipId;
                this.reversed = true;
                this.contact1_Id = contact2_Id;
                this.contact1_Name = name2;
                this.relationship1 = relationship2;
                this.contact2_Id = contact1_Id;
                this.contact2_Name = name1;
                this.relationship2 = relationship1;
            }
        }
        
    }
}