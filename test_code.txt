Account myAccount = [SELECT Id FROM Account WHERE Name = 'Banana Man Inc.' LIMIT 1];

//Id myDocumentId = '[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = myAccount.Id  LIMIT 1]'; // ID of a Salesforce Document library record.


// Create an empty envelope and add a Salesforce Document and embedded signer recipient.
// The embedded signer will be the current user with sequence and routing order 1 and role "Signer 1" by default.
dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
   new dfsle.Entity(myAccount.Id)); // The initiating Salesforce entity.

//Find your contact to add
Contact myContact = [SELECT Id, Name, Email FROM Contact WHERE Name = 'Banana Man' LIMIT 1];


//use the Recipient.fromSource method to create the Recipient
dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
           myContact.Name, // Recipient name
           myContact.Email, // Recipient email
           null, //Optional phone number
           'Signer 1', //Role Name. Specify the exact role name from template
           new dfsle.Entity(myContact.Id)); //source object for the Recipient - Account



//add Recipient to the Envelope
myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });


//myTemplateId contains the DocuSign Id of the DocuSign Template
dfsle.UUID myTemplateId = dfsle.UUID.parse('f7e51f35-a2fd-4918-8920-ce5e6306b013');

//create a new document for the Envelope
dfsle.Document myDocument = dfsle.Document.fromTemplate(
   myTemplateId, // templateId in dfsle.UUID format
   'myTemplate'); // name of the template

//add document to the Envelope
myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument });

// Send the envelope.
myEnvelope = dfsle.EnvelopeService.sendEnvelope(
   myEnvelope, // The envelope to send
   true); // Send now?
