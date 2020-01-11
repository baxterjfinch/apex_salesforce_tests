//Set<Id> eContracts = new Set<Id>{'0Q08E000002nTC2SAM', '0Q08E000002nTApSAM'};
Set<Id> eContracts = new Set<Id>{ '8004P000000KusgQAC'};
List<Quote> quotesByQuoteId = [SELECT Id,
Opportunity.Primary_Contact__c,
Opportunity.Primary_Contact__r.Name,
Opportunity.Primary_Contact__r.Email,
(SELECT Id, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLinks)
FROM Quote
WHERE Id IN :eContracts];

for (Quote esignatureContract : quotesByQuoteId) {
try {
dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
new dfsle.Entity(esignatureContract.Id)
);

dfsle.EnvelopeService.createEnvelope(myEnvelope, null, true); 

dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
esignatureContract.Opportunity.Primary_Contact__r.Name,
esignatureContract.Opportunity.Primary_Contact__r.Email,
null,
'Signer 1',
new dfsle.Entity(esignatureContract.Opportunity.Primary_Contact__c)
);

myEnvelope = myEnvelope.withRecipients(
new List<dfsle.Recipient> { myRecipient }
);

List<dfsle.Document> documents = dfsle.DocumentService.getDocuments(
ContentVersion.getSObjectType(),
new Set<Id> {
esignatureContract.ContentDocumentLinks[0].ContentDocument.LatestPublishedVersionId
}
);

myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { documents[0] });

dfsle.Notifications myNotification = new dfsle.Notifications(
true, 1, 1, true, 3, 2, false
);
myEnvelope = myEnvelope.withNotifications(myNotification);

myEnvelope = dfsle.EnvelopeService.sendEnvelope(
myEnvelope,
true
);

} catch (Exception ex) {
system.debug(ex.getMessage());
}
}
