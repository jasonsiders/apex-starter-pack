# TriggerHandler

Does the world really need another Trigger Handler framework? Probably not. But I like this one, and it walks the fine line between simplicity and functionality in a way that I believe will be useful to others.

`TriggerHandler` allows for proper implementation of Separation of Concerns. Other nice features include bypass, built-in filtering, and DI/mocking support. When used properly, these features can allow developers to create and maintain trigger code cleanly and efficiently, with minimal overhead.

To see the `TriggerHandler` framework in action, you can view this repository's `LogEventHandler` class [here](../Logger/LogEventHandler.cls).

## Creating a Handler Class

For each trigger, developers must create a handler class which extends the abstract `TriggerHandler` class.

`TriggerHandler` has one abstract method, which developers are required to implement:

-   Type `getHandlerType()`: Returns the `Type` of the current apex class.

To define what code will run in each [TriggerOperation](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_TriggerOperation.htm), override the corresponding virtual method:

-   void `beforeInsert()`
-   void `beforeUpdate()`
-   void `beforeDelete()`
-   void `afterInsert()`
-   void `afterUpdate()`
-   void `afterDelete()`
-   void `afterUndelete()`

Here's an example implementation:

```
public class AccountTriggerHandler extends TriggerHandler {
    public override Type getHandlerType() {
        // This method always returns the current type. Needed for bypass purposes
        return AccountTriggerHandler.class;
    }

    public override void beforeInsert() {
        AccountService.doSomething(this.triggerNew);
    }

    public override void afterUpdate() {
        AccountService.doSomethingElse(this.triggerNew);
    }
}
```

Once created, it takes just one line to wire up the handler class to the Trigger:

```
trigger AccountTrigger on Account (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    new AccountTriggerHandler().run();
}
```

## Features

`TriggerHandler` comes equipped with a number of extra features to maximize flexibility and testability. Developers can use the following features in their production and test code to quickly spin up trigger logic with minimal overhead.

### **Bypass**

By default, all `TriggerHandler` classes are "active". However, developers can choose to temporarily bypass all, or specific `TriggerHandler` classes in their code. When a handler class is bypassed, the `run()` method will not call any of the [TriggerOperation](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_TriggerOperation.htm) virtual methods.

Use the following static methods to control the bypass mechanism:

-   `TriggerHandler.disable()`
    -   Disables all `TriggerHandler` classes.
-   `TriggerHandler.disable(Type handlerType)`
    -   Disables a specific `TriggerHandler` class.
-   `TriggerHandler.enable(Type handlerType)`
    -   Enables the specific `TriggerHandler` class. Other handlers that were previously bypassed via `disable(handlerType)` will remain disabled.
-   `TriggerHandler.enable()`
    -   Enables all `TriggerHandler` classes, excluding all that were previously bypassed via `disable(handlerType)`.
-   `TriggerHandler.enableAll()`
    -   Enables all `TriggerHandler` classes, including all that were previously bypassed via `disable(handlerType)`.

The bypass mechanism has a couple of obvious applications. It can be used to prevent triggers from running during `@TestSetup`, a common problem when testing trigger code:

```
@TestSetup
static void setup() {
    TriggerHandler.disable(AccountTriggerHandler.class);
    insert new Account(Name = 'Test Account');
    TriggerHandler.enableAll();
}
```

It can also be used to bypass triggers for operations that require maximum performance. This example implements a bypass in an API integration:

```
@HttpPost
global static void importLeads() {
    List<Lead> leads = (List<Lead>) JSON.deserialize(
        RestContext?.Request?.requestBody,
        List<Lead>.class
    );
    // Prevent timeout errors
    TriggerHandler.disable();
    update leads;
}
```

### **Filtering**

Record-triggered automation tends to have a lot of conditional logic. This logic tends to be straightfowrad in declarative automation tools, thanks to Salesforce's built in `ISCHANGED()` and `ISNEW()` formulas. There is no parallel to this in Salesforce, and so developers often write code like this:

```
List<Account> highValueAccs = new List<Account>();
for (Account acc : Trigger.new) {
    // If not new, and BillingCountry changes from null to 'US'
    if (
        Trigger.oldMap?.containsKey(acc.Id) == false &&
        Trigger.oldMap.get(acc.Id)?.BillingCountry == null &&
        acc.BillingCountry = 'US'
    ) {
        highValueAccs.add(acc);
    }
}
```

This works, but it's overly verbose and does not properly communicate intent. `TriggerHandler` provides a number of instance methods to make business logic more palatable:

-   `isNew(SObject record)`
    -   Returns `true` if the record is new
-   `isChanged(SObject record, SObjectField field)`
    -   Returns `true` if the specified field was changed on the record.
-   `isChangedFrom(SObject record, SObjectField field, Object fromValue)`
    -   Returns `true` if the specified field was changed on the record _from_ the specified `fromValue`.
-   `isChangedTo(SObject record, SObjectField field, Object toValue)`
    -   Returns `true` if the specified field was changed on the record _to_ the `toValue`.
-   `isChanged(SObject record, SObjectField field, Object fromValue, Object toValue)`
    -   Returns `true` if the specified field was changed on the record _from_ the `fromValue` _to_ the `toValue`.

Here's that same example above, rewritten using these methods:

```
// In AccountTriggerHandler.cls
List<Account> highValueAccs = new List<Account>();
for (Account acc : Trigger.new) {
    // If not new, and BillingCountry changes from null to 'US'
    if (
        !this.isNew(acc) &&
        this.isChangedFromTo(acc, Account.BillingCountry, null, 'US');
    ) {
        highValueAccs.add(acc);
    }
}
```

If more powerful filtering is required, the `CollectionUtils` class provides additional options:

```
List<Account> highValueAccs = (List<Account>) CollectionUtils.filterCollection(
    this.triggerNew,
    new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 0),
    List<Account>.class
);
```

### **Dependency Injection/Mocking**

The `TriggerHandler` has several instance properties that wrap commonly used static`Trigger` properties during a `Trigger.isExecuting` context.

-   `triggerNew`
    -   `Trigger.new` during Trigger execution. Else, an empty `List<SObject>`.
-   `triggerNewMap`
    -   `Trigger.newMap` during Trigger execution. Else, an empty `Map<Id, SObject>`.
-   `triggerOld`
    -   `Trigger.old` during Trigger execution. Else, an empty `List<SObject>`.
-   `triggerOldMap`
    -   `Trigger.oldMap` during Trigger execution. Else, an empty `Map<Id, SObject>`.
-   `operation`
    -   `Trigger.operationType` during Trigger execution. Else, is null.

Since each of these properties are `@TestVisible`, developers can artificially inject mock dependencies into each.

```
@IsTest
static void testBeforeInsert() {
    Account testAcc = new Account(
        Id = DmlMock.generateFakeId(Account.SObjectType),
        Name = 'Test Account'
    );
    TriggerHandler handler = new AccountTriggerHandler();
    handler.triggerNew.add(testAcc);
    handler.operation = TriggerOperation.BEFORE_INSERT;
    handler.run();
}
```

This allows developers to decouple the handler code from the trigger itself for test purposes. This allows for easier, and more thorough unit tests.
