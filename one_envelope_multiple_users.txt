List<Contact> myContacts = new List<Contact>();
List<dfsle.Recipient> myRecipients = new List<dfsle.Recipient>();
List<OpportunityContactRole> oppContactRoles = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = '0064P00000lh9pVQAQ'];

for (OpportunityContactRole contactRole : oppContactRoles) {
    try {
        Contact contact = [SELECT Name, Email, Id FROM Contact WHERE Id = :contactRole.ContactId];
		dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
            contact.Name,
            contact.Email,
            null,
            'Signer 1',
            new dfsle.Entity(contact.Id)
        );

        myContacts.add(contact);
        myRecipients.add(myRecipient);

    }
    catch (Exception ex) {
    	system.debug(ex.getMessage());
    }
}

//Build Envelope
dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
    	new dfsle.Entity('0064P00000lh9pVQAQ'));

// Add List of Recipients
myEnvelope = myEnvelope.withRecipients(myRecipients);

//create a new document for the Envelope with Template
dfsle.UUID myTemplateId = dfsle.UUID.parse('f7e51f35-a2fd-4918-8920-ce5e6306b013');
dfsle.Document myDocument = dfsle.Document.fromTemplate(
    myTemplateId, // templateId in dfsle.UUID format
    'myTemplate'); // name of the template

//Apply Documents To Envelope
myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument });

//Send
myEnvelope = dfsle.EnvelopeService.sendEnvelope(
    myEnvelope, // The envelope to send
    true); // Send now?
