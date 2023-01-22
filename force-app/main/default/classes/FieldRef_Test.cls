@IsTest
private class FieldRef_Test {
	@IsTest
	static void shouldConstructFromSingleField() {
		SObjectField field = Account.Name;
		FieldRef ref = new FieldRef(field);
		System.assertEquals('Name', ref.toString(), 'Wrong SOQL reference');
		System.assertEquals(field, ref.toSchemaType(), 'Wrong destination SObjectField');
	}

	@IsTest
	static void shouldConstructFromChainOfRelatedFields() {
		List<SObjectField> fields = new List<SObjectField>{ Case.ContactId, Contact.AccountId, Account.Name };
		FieldRef ref = new FieldRef(fields);
		System.assertEquals('Contact.Account.Name', ref.toString(), 'Wrong SOQL reference');
		System.assertEquals(Account.Name, ref.toSchemaType(), 'Wrong destination SObjectField');
	}

	@IsTest
	static void simpleFieldShouldBeSerializable() {
		SObjectField field = Account.Name;
		System.assertNotEquals(null, testSerialize(field), 'SObjectField is serializable?');
		FieldRef ref = new FieldRef(field);
		System.assertEquals(null, testSerialize(ref), 'FieldRef is not serializable?');
		// After serializiation, should still function the same as before
		FieldRef deserializedRef = (FieldRef) JSON.deserialize(JSON.serialize(ref), FieldRef.class);
		Account testAcount = new Account(Name = 'Foo');
		System.assertEquals(
			testAcount.Name,
			deserializedRef.getValue(testAcount),
			'Post-serialization, could not retrieve the correct field value'
		);
	}

	@IsTest
	static void complexFieldShouldBeSerializable() {
		List<SObjectField> fields = new List<SObjectField>{ Case.ContactId, Contact.AccountId, Account.Name };
		FieldRef ref = new FieldRef(fields);
		System.assertEquals(null, testSerialize(ref), 'FieldRef is not serializable?');
		// After serializiation, should still function the same as before
		FieldRef deserializedRef = (FieldRef) JSON.deserialize(JSON.serialize(ref), FieldRef.class);
		Account testAccount = new Account(Name = 'Foo');
		Contact testContact = (Contact) SObjectUtils.setLookupField(new Contact(), Contact.AccountId, testAccount);
		Case testCase = (Case) SObjectUtils.setLookupField(new Case(), Case.ContactId, testContact);
		System.assertEquals(
			testAccount.Name,
			deserializedRef.getValue(testCase),
			'Post-serialization, could not retrieve the correct field value'
		);
	}

	@IsTest
	static void shouldThrowErrorIfGettingFieldFromSObjectOfWrongType() {
		Account testAccount = new Account(Name = 'Test');
		Contact testContact = (Contact) SObjectUtils.setLookupField(new Contact(), Contact.AccountId, testAccount);
		FieldRef ref = new FieldRef(Account.Name);

		Test.startTest();
		Exception caughtError;
		try {
			ref.getValue(testContact); // ! Account.Name is not a column on Contact.SObjectType
		} catch (System.SObjectException thrownError) {
			caughtError = thrownError;
		}
		Test.stopTest();

		System.assertNotEquals(null, caughtError, 'An error was not thrown');
	}

	@IsTest
	static void shouldBeUsableAsAMapKey() {
		Map<FieldRef, String> fieldMap = new Map<FieldRef, String>();
		List<SObjectField> chainedFields = new List<SObjectField>{ Case.ContactId, Contact.AccountId, Account.Name };
		List<FieldRef> fieldReferences = new List<FieldRef>{
			new FieldRef(chainedFields),
			new FieldRef(Case.ContactId),
			new FieldRef(Contact.AccountId),
			new FieldRef(Account.Name)
		};
		for (FieldRef fieldReference : fieldReferences) {
			fieldMap.put(fieldReference, fieldReference.toString());
		}

		Test.startTest();
		FieldRef ref = new FieldRef(chainedFields);
		for (FieldRef fieldReference : fieldReferences) {
			FieldRef newRef = fieldReference.clone();
			System.assertEquals(true, fieldMap.containsKey(newRef), 'Map does not contain ' + newRef);
		}
		Test.stopTest();
	}

	// **** HELPER **** //
	static Exception testSerialize(Object obj) {
		Exception caughtError;
		try {
			JSON.serialize(obj);
		} catch (System.JSONException jsonError) {
			caughtError = jsonError;
		}
		return caughtError;
	}
}
