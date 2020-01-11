public class AlluraClass implements Queueable, Database.AllowsCallouts {
    public Id opportunityId;
    public Id oppDocId;
    public List<dfsle.Recipient> myRecipients;
    public List<OpportunityContactRole> oppContactRoles;
    public List<Opportunity> oppOwner;
    public List<dfsle.Document> documents;
    public dfsle.Envelope myEnvelope;

    public void AlluraClass(String id) {
        this.opportunityId = id;
        this.myRecipients = new List<dfsle.Recipient>();
    }

    public void execute(QueueableContext context) {
        //1.) Get Opp Owner
        this.getOppOwner();
        //2.) Get versioned document from opportunity
        this.getOppDocumentId();
        //3.) Build Recipients
        this.buildRecipients();
        //4.) Build and Send envelope
        this.buildEnvelope();
        //5.) Send envelope
        dfsle.EnvelopeService.sendEnvelope(this.myEnvelope, true);
    }

    public void getOppOwner() {
        this.oppOwner = [SELECT Owner.Name, Owner.Email, Owner.Id FROM Opportunity o WHERE o.Id =: this.opportunityId];
    }

    public void getOppDocumentId() {
        List<ContentDocumentLink> oppDocs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: this.opportunityId];
        Id oppDoc = oppDocs[0].ContentDocumentId;

        for (ContentVersion cv : [
            SELECT ContentDocumentId FROM ContentVersion
            WHERE OwnerId =: this.oppOwner[0].Owner.Id
        ]) {
            if (cv.ContentDocumentId == oppDoc) {
                this.oppDocId = cv.Id;
            }
        }
    }

    public void buildRecipients() {
        // Add opportunity owner as recipient #1
        dfsle.Recipient mySender = dfsle.Recipient.fromSource(
            this.oppOwner[0].Owner.Name, // Name
            this.oppOwner[0].Owner.Email, // Email
            null,
            'Signer 1',
            new dfsle.Entity(this.oppOwner[0].Owner.Id));
        this.myRecipients.add(mySender);

        // Add client contact as recipient #2
        for (OpportunityContactRole m : [
            SELECT ContactId FROM OpportunityContactRole
            WHERE OpportunityId =: this.opportunityId
        ]) {
            Contact contact = [SELECT Name, Email, Id FROM Contact WHERE Id = :m.ContactId];
            dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                contact.Name, // Name
                contact.Email, // Email
                null,
                'Signer 2',
                new dfsle.Entity(contact.Id));
            this.myRecipients.add(myRecipient);
        }
    }

    public void buildEnvelope() {
        List<dfsle.Document> myDocuments = dfsle.DocumentService.getDocuments(
            ContentVersion.getSObjectType(),
            new Set<Id> { this.oppDocId }
        );

        this.myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
            new dfsle.Entity(this.opportunityId));
        this.myEnvelope = this.myEnvelope.withRecipients(this.myRecipients);
        this.myEnvelope = this.myEnvelope.withDocuments( myDocuments );
    }
}
