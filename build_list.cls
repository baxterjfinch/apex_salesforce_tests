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

// Take this and add it to your next script
Id myListId = myList.id;
