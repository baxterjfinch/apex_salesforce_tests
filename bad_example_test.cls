
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
    public dfsle.Envelope draftEnvelope;

    private Id myFileId;
    private Id myListId;

    public GetDraftClass(Id myFileId, Id myListId) {
        this.myFileId = myFileId;
        this.myListId = myListId;
    }

    public void execute(QueueableContext context) {
        this.draftEnvelope = dfsle.BulkSendService.getDraftEnvelope(
            dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { this.myFileId }), // Documents to send
            null);
    }
}

try {
    GetDraftClass getDraftJob = new GetDraftClass('0684P000008MMyuQAG', myListId);
    ID jobID = System.enqueueJob(getDraftJob);
    sleep(5);
    System.debug('***********************************************');
    System.debug(getDraftJob.draftEnvelope);
    SendEnvelopeClass sendEnvelopeJob = new SendEnvelopeClass(getDraftJob.draftEnvelope, myListId);
    ID jobID2 = System.enqueueJob(sendEnvelopeJob);
}
catch (Exception ex) {
    system.debug(ex.getMessage());
}
