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

dfsle.BulkList myList = dfsle.BulkSendService.createLists(new List<dfsle.BulkList> {
	dfsle.BulkList.newList(
		'My bulk list', // List name
		myBulkCopies, // Envelope copies
		new dfsle.Entity('0064P00000lh9pVQAQ')) // The Salesforce source object
})[0];

Id myListId = myList.id;

public class GetDraftClass {
    public dfsle.Envelope draftEnvelope;

    public GetDraftClass(Id myFileId, Id myListId) {
        try {
            List<dfsle.Document> draftDocs = dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { myFileId });
            this.draftEnvelope = dfsle.BulkSendService.getDraftEnvelope(draftDocs, null);
        } catch(Exception ex){
            System.debug('BulkSendService.getDraftEnvelope Failure: ' + ex.getMessage());
        }
    }
}

public class SendEnvelopeClass {
    public dfsle.BulkList.Result finishedEnvelope;

    public SendEnvelopeClass(dfsle.Envelope myEnvelope, Id myListId) {
        try {
            this.finishedEnvelope = dfsle.BulkSendService.sendEnvelope(myListId, myEnvelope);
        } catch(Exception ex){
            System.debug('dfsle.BulkSendService.sendEnvelope Failure: ' + ex.getMessage());
        }
    }
}

try {
    GetDraftClass getDraftJob = new GetDraftClass('0684P000008MMyuQAG', myListId);
    SendEnvelopeClass sendEnvelopeJob = new SendEnvelopeClass(getDraftJob.draftEnvelope, myListId);

    dfsle.BulkList.Result finishedEnvelope = sendEnvelopeJob.finishedEnvelope;
    Id myStatusId = finishedEnvelope.bulkStatusId;
    dfsle.BulkList.Status myStatus = dfsle.BulkSendService.getStatus(new Set<Id> { myStatusId })[0];

	if (myStatus.queuedEnvelopes > 0) {
        System.debug('Envelopes Queued For Processing...');
    } else if (myStatus.failedEnvelopes > 0) {
        System.debug('Failed');
    }

}
catch (Exception ex) {
    system.debug(ex.getMessage());
}
