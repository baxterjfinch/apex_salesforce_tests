// This scrypt uses the BulkSendService to send an individual recipient their
// own envelope. The problem that occurs is related to a DML that I suspsect
// originates from a @futures or callback method that is in the Apex Toolkit

// Specifically, it seems like a Salesforce Object is being updated when the
// BulkSendService.sendEnvelope is called for the first envelope in the list.
// It returns with a DML error stating that a Salesforce Object is being updated
// but not commited to the database before calling back to my application

// Dev has been contacted and will report back to kevin with their estimation
// of the cause of the issue


List<dfsle.Envelope> myBulkCopies = new List<dfsle.Envelope>();
List<OpportunityContactRole> oppContactRoles = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = '0064P00000lh9pVQAQ'];

for (OpportunityContactRole m : [
	SELECT ContactId FROM OpportunityContactRole
	WHERE OpportunityId = '0064P00000lh9pVQAQ'
]) {
    Contact contact = [SELECT Name, Email, Id FROM Contact WHERE Id = :m.ContactId];
	myBulkCopies.add(dfsle.Envelope.newBulkCopy(
		dfsle.Recipient.newBulkRecipient(
			contact.Name, // Name
			contact.Email, // Email
			new dfsle.Entity(contact.Id)))); // Source Salesforce object
}

// Create the bulk list. This list persists after sending and may be reused for multiple envelopes.
dfsle.BulkList myList = dfsle.BulkSendService.createLists(new List<dfsle.BulkList> {
	dfsle.BulkList.newList(
		'My bulk list', // List name
		myBulkCopies, // Envelope copies
		new dfsle.Entity('0064P00000lh9pVQAQ')) // The Salesforce source object
})[0];

// Save the ID for later operations
Id myListId = myList.id;

public class SendEnvelopeClass implements Queueable {
    private dfsle.Envelope draftEnvelope;
    private Id myListId;

    public SendEnvelopeClass(dfsle.Envelope myEnvelope, Id myListId) {
        this.draftEnvelope = myEnvelope;
        this.myListId = myListId;
    }

    public void execute(QueueableContext context) {
        dfsle.BulkSendService.sendEnvelope(this.myListId, this.draftEnvelope);
    }
}

public class GetDraftClass implements Queueable {
    private Id myFileId;
    public dfsle.Envelope draftEnvelope;

    public GetDraftClass(Id myFileId) {
        this.myFileId = myFileId;
    }

    public void execute(QueueableContext context) {
        this.draftEnvelope = dfsle.BulkSendService.getDraftEnvelope(
            dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { this.myFileId }), // Documents to send
            null);
    }
}

try {
    GetDraftClass getDraftJob = new GetDraftClass('0684P000008MMyuQAG');
    ID jobID = System.enqueueJob(getDraftJob);

    SendEnvelopeClass sendEnvelopeJob = new SendEnvelopeClass(getDraftJob.draftEnvelope, myListId);
    ID jobID2 = System.enqueueJob(sendEnvelopeJob);
}
catch (Exception ex) {
    system.debug(ex.getMessage());
}
