// Created by first script
Id myListId = 'a0F4P00000LNSSIUA5';

public class GetDraftClass {
    public dfsle.Envelope draftEnvelope;

    public GetDraftClass(Id myFileId) {
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
    // Send the Document Version ID and the myListId into GetDraftClass to build
    // out the draft envelope
    GetDraftClass getDraftJob = new GetDraftClass('0684P000008MMyuQAG');
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
