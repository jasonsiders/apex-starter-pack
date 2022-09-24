@IsTest
private class ChildRelationshipRef_Test {
	@IsTest
	static void shouldConstrcutFromChildRelationship() {
		ChildRelationship rel = SchemaUtils.getChildRelationship(Contact.AccountId);

		Test.startTest();
		ChildRelationshipRef ref = new ChildRelationshipRef(rel);
		Test.stopTest();

		System.assertEquals(rel, ref?.toSchemaType(), 'Wrong ChildRelationship');
		System.assertEquals('Account.Contacts', ref.toString(), 'Wrong toString() value');
	}

	@IsTest
	static void shouldConstructFromLookupField() {
		SObjectField field = Contact.AccountId;

		Test.startTest();
		ChildRelationshipRef ref = new ChildRelationshipRef(field);
		Test.stopTest();

		System.assertEquals(field, ref?.toSchemaType()?.getField(), 'Wrong ChildRelationship.getField()');
		System.assertEquals('Account.Contacts', ref.toString(), 'Wrong toString() value');
	}

	@IsTest
	static void shouldThrowErrorIfNotLookupField() {
		SObjectField field = Contact.LastName; // ! Not a lookup field!

		Test.startTest();
		Exception caughtError;
		try {
			ChildRelationshipRef ref = new ChildRelationshipRef(field);
		} catch (ChildRelationshipRef.InvalidFieldException thrownError) {
			caughtError = thrownError;
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown for an invalid field');
	}

	@IsTest
	static void shouldBeSerializable() {
		// Note: Unlike the other Schema objects, ChildRelationship seems to be serializable in synchronous contexts
		// However, it's still not serializable in asynchronous operations (like Queueable/Batchable)
		ChildRelationshipRef ref = new ChildRelationshipRef(Contact.AccountId);
		// Populating the `ChildRelationship` property should cause an error
		Exception caughtError;
		try {
			ChildRelationship rel = ref?.toSchemaType();
			System.enqueueJob(new AsyncContainer(rel));
		} catch (System.SerializationException thrownError) {
			caughtError = thrownError;
		}
		System.assertNotEquals(null, caughtError, 'No issue serializing ChildRelationship in async-context');

		// Populating the `ChildRelationshipRef` property instead should not cause an error
		try {
			System.enqueueJob(new AsyncContainer(ref));
		} catch (System.SerializationException thrownError) {
			System.assert(false, 'Not safe for serialization!');
		}
	}

	@IsTest
	static void shouldBeUsableAsAMapKey() {
		Map<ChildRelationshipRef, SObjectField> refs = new Map<ChildRelationshipRef, SObjectField>();
		List<SObjectField> lookupFields = new List<SObjectField>{
			Case.AccountId,
			Contact.AccountId,
			Opportunity.AccountId
		};
		for (SObjectField lookupField : lookupFields) {
			refs.put(new ChildRelationshipRef(lookupField), lookupField);
		}

		for (SObjectField lookupField : lookupFields) {
			ChildRelationshipRef newRef = new ChildRelationshipRef(lookupField);
			System.assertEquals(true, refs.containsKey(newRef), 'Map does not contain ' + newRef.toString());
		}
	}
	
	@IsTest 
    static void shouldReturnHashCode() {
        // Mapping test above doesn't always use the hashCode() method
        // This is mostly for test coverage
        ChildRelationshipRef obj = new ChildRelationshipRef(Opportunity.AccountId);
        System.assertNotEquals(null, obj.hashCode(), 'Null hashCode');
    }

	// **** HELPER **** //
	public class AsyncContainer implements System.Queueable {
		ChildRelationshipRef reference;
		ChildRelationship relationship;

		public AsyncContainer(ChildRelationshipRef reference) {
			this.reference = reference;
		}

		public AsyncContainer(ChildRelationship relationship) {
			this.relationship = relationship;
		}

		public void execute(System.QueueableContext context) {
			// Do nothing!
		}
	}
}
