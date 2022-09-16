# DatabaseLayer

Apex's tight integration with its inline SOQL queries and DML provide many benefits, but these come at the cost of a hidden dependency: the Salesforce database itself.

Because DML, SOQL, and SOSL queries all take time to process, Salesforce [excludes these operations](https://help.salesforce.com/s/articleView?id=000339361&type=1) from Apex CPU Time limits. This is all well and good in production code, but even efficient database operations can cause issues at scale in test code. Because of this, it's widely considered a best practice to mock database operations (DML and SOQL) where possible in your unit tests.

`DatabaseLayer` is designed to be your one-stop shop for handling database operations in Apex, and it allows for easy mocking in Apex tests.

## Contents

-   [The `DatabaseLayer` Class](#the-database-layer-class)
-   [DML](#dml)
    -   [The `Dml` Class](#the-dml-class)
    -   [The `AsyncDml` Class](#the-async-dml-class)
    -   [Mocking DML](#mocking-dml)
    -   [The `Dml.History` Class](#the-dml-history-class)
-   [Queries](#queries)
    -   [The `Soql` Class](#the-soql-class)
    -   [Related Classes](#related-classes)
    -   [Usage](#usage)
    -   [Mocking SOQL](#mocking-soql)

---

## The `DatabaseLayer` Class

The class primarily consists of two public static variables: `Dml` and `Soql`. Developers should use these classes in place of all inline DML and SOQL operations.

Replace all DML operations (including `insert`, `update`, `upsert`, `delete`, `undelete`, and the `Database` class's DML methods) with a call to `DatabaseLayer.Dml`:

```
DatabaseLayer.Dml.doInsert(records);
```

Replace all SOQL operations (both inline and dynamic soql) with a call to `DatabaseLayer.Soql`:

```
DatabaseLayer.Soql.newQuery(Account.SObjectType);
```

In `@IsTest` context, developers can replace one or both of the existing "engines" that drive database operations, using the following code:

```
DatabaseLayer.setDmlEngine(new DmlMock());
DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
```

---

## DML

### **The `Dml` Class**

The `Dml` class was designed to centralize data manipulation logic in a codebase.

**Note:** Though this class has a public constructor, it shouldn't be instantiated directly. Instead, get the current instance via `DatabaseLayer.Dml`.

The `Dml` class provides a number of methods that handle DML operations:

-   `doInsert()`: Insert record(s).
-   `doUpdate()`: Update record(s).
-   `doUpsert()`: Upsert record(s). Callers can optionally provide an `SObjectField` to use as the external key.
-   `doDelete()`: Delete record(s).
-   `doHardDelete()`: Delete record(s), and immediately remove them from the recycling bin.
-   `doUndelete()`: Undelete record(s) that have not yet been hard deleted.
-   `doConvert()`: Convert Lead record(s).
-   `doDml()`: For use in dynamic operations. Callers must provide a `Dml.Operation` enum value, in addition to record(s). See [**The `Dml.Operation` Enum**](#the-dml-operation-enum) for more information.

#### **The `DmlResult` Class**

Each of the `Dml` methods describe above returns a `DmlResult` or `List<DmlResult>`. The `DmlResult` class wraps the various standard `Database` result classes, which cannot be manually constructed or mocked, and somehow don't share a common interface or base type, despite being incredibly similar:

-   `Database.SaveResult`: Returned in `insert` and `update` operations.
-   `Database.UpsertResult`: Returned in `upsert` operations.
-   `Database.DeleteResult`: Returned in `delete` operations.
-   `Database.UndeleteResult`: Returned in `undelete` operations.

The `DmlResult` class expose a number of public properties common to each of these types:

-   `errors` (`List<DmlResult.Error>`): Any errors that were produced in the DML operation. This type wraps the `Database.Error` class, which also cannot be manually constructed or mocked in tests.
-   `isSucess` (`Boolean`): Indicates whether the DML operation was successful.
-   `recordId` (`Id`): The Id of the SObject submitted for DML.

#### **The `Dml.Operation` Enum**

In certain situations, developers may need to execute a DML operation without knowing the exact operation type at runtime. In this unique use case, developers may pass a `Dml.Operation` enum value to the `Dml` class's `doDml()` method:

```
DatabaseLayer.Dml.doDml(Dml.Operation.DO_UPSERT, accounts, Account.Customer_UUID__c);
```

The `Dml.Operation` enum consists of the following values:

-   `DO_PUBLISH`,
-   `DO_INSERT`,
-   `DO_UPDATE`,
-   `DO_UPSERT`,
-   `DO_DELETE`,
-   `DO_UNDELETE`,
-   `DO_HARD_DELETE`

### **The `AsyncDml` Class**

Developers may occasionally need to process DML asynchronously. The `AsyncDml` class can be used to push DML operations into its own execution context via a `Queueable`.

Each DML operation is represented by an object, `AsyncDml.Request`. The Request object accepts the following parameters in the constructor:

-   `operation` (`Dml.Operation`): An enum value which describes the operation type. Ex., `Dml.Operation.DO_INSERT`. See [**The `Dml.Operation` Enum**](#the-dml-operation-enum) for more information.
-   `record`/`records` (`SObject`/`List<SObject>`): The SObject record(s) to operate on.
-   `externalIdField` (`SObjectField`): Field which acts as a key for upsert operations.
-   `allOrNone` (`Boolean`): Determines whether the operation allows partial success. If you specify `false` for this parameter and a record fails, the remainder of the DML operation can still succeed.

### **Mocking DML**

The `DmlMock` class is responsible for mocking DML operations. It is only visible in the `@IsTest` context.

All DML statements will automatically be mocked if the `DatabaseLayer.Dml` is an instance of `DmlMock`. Developers can set this with the below code:

```
DatabaseLayer.setDmlEngine(new DmlMock());
```

Mocking generally involves assigning new records with a fake Id signature, derived from its `SObjectType`'s key prefix. For example:

```
Account acc = new Account(Name = 'Test');
DatabaseLayer.Dml.doInsert(acc);
System.debug(acc.Id);
// > "001000000000000000"
```

> **Note:** Mocked records only exist in memory; they are not actually committed to the Database. Because of this, any SOQL queries that point at mock-manipulated data may fail to return results. These queries to should also be mocked (see [**Mocking SOQL**](#mocking-soql) for more information).

### The `Dml.History` Class

Both `Dml` and `DmlMock` utilize a series of public `Dml.History` objects to record SObjects that are submitted for DML Operations during a transaction:

-   `Inserted`: Stores records that were updated.
-   `Updated`: Stores records that were updated.
-   `Upserted`: Stores records that were upserted.
-   `Deleted`: Stores records that were deleted.
-   `Undeleted`: Stores records that were undeleted.
-   `Published`: Stores [Platform Event](https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_events_intro.htm) records that were published.
-   `Converted`: Stores Lead records that were converted.

`Dml.History` methods include:

-   `containsRecord()`: Returns `true` if the given record/Id is included.
-   `getRecord()`: Returns any record(s) which match the given Id/SObject/SObjectType.
-   `getAll()`: Returns all records stored in the history object.
-   `clear()`: Reset the history object.

> **Note:** In `@IsTest` context, you can clear all history objects via the `DmlMock.resetHistory()` static method.

These `Dml.History` objects can be especially helpful for testing methods which insert or transform other objects not currently in memory:

```
@IsTest
static void shouldInsertOpportunities() {
    DatabaseLayer.setDmlEngine(new DmlMock());
    Account acc = new Account(Name = 'Test Acc');
    DatabaseLayer.doInsert(acc);
    DatabaseLayer.Inserted.clear();

    Test.startTest();
    AccountDomain.createNewOpportunity(acc);
    Test.stopTest();

    List<Opportunity> newOpps = DatabaseLayer.Dml.Inserted.getRecords(Opportunity.SObjectType);
    System.assertEquals(1, newOpps?.size(), 'Wrong # of Opps');
    System.assertEquals(acc.Id, newOpps[0].AccountId, 'Wrong AccountId');
}
```

---

## Queries

### **The `Soql` Class**

The `Soql` class was designed to centralize query logic in a codebase.

**Note:** Though this class has a public constructor, it shouldn't be instantiated directly. Instead, get the current instance via `DatabaseLayer.Soql`.

Inline SOQL is one of the most used features of Apex, due to its type safety and extreme ease of use.

```
List<Account> accounts = [
    SELECT Id
    FROM Account
    WHERE My_Field__c = 'foo'
];
```

While this is good, there are some real problems hidden behind the surface. First, inline SOQL doesn't have any options for code-reuse. If we wanted to add/change criteria to the above query, we'd have to write a whole new one:

```
List<Account> otherAccs = [
    SELECT Id, My_Field__c, My_Other_Field__c
    FROM Account
    WHERE My_Field__c = 'foo'
    OR My_Other_Field__c = 'bar'
    ORDER BY CreatedDate DESC
    LIMIT 100
];
```

We _could_ use a dynamic SOQL query to get the job done...

```
List<String> selectFields = new List<String>{
    String.valueOf(Account.Id),
    String.valueOf(Account.My_Field__c),
    String.valueOf(Account.My_Other_Field__c)
};
SObjectType fromSObject = Account.SObjectType;
String whereClause = Account.My_Field__c + ' = \'foo\' AND ' + Account.My_Other_Field__c + ' = \'bar\'';
SObjectField orderByField = Account.CreatedDate;
Integer recordLimit = 100;
String soql = String.format(
    'SELECT {0} FROM {1} WHERE {2} ORDER BY {3} LIMIT {4}',
    new List<String>{
        String.join(selectFields, ','),
        String.valueOf(fromSObject),
        whereClause,
        String.valueOf(orderByField),
        String.valueOf(recordLimit)
    }
);
List<Account> accounts = (List<Account>) Database.query(soql);
```

But this is even worse! In addition to being _incredibly_ messy and verbose, our dynamic SOQL not much more flexible than the first solution. Additionally, the reliance on "magic strings" makes me nervous about type safety, and even more nervous about the potential for typos. Every dynamic SOQL I've written in my career has always felt just moments away from a `System.QueryException` in production.

Enter the `Soql` class. **Soql** is an object-oriented query builder in Apex. It can be used to create query objects which can then be run against the database, or mocked in tests. Here it is in action, with our example query from above:

```
Soql query = DatabaseQuery.Soql.newQuery(Account.SObjectType)
    .selectFields(Account.My_Field__c)
    .selectFields(Account.My_Other_Field__c)
    .whereFilters(new Filter(Account.My_Field__c, Filter.EQUALS, 'foo'))
    .whereFilters(new Filter(Account.My_Other_Field__c, Filter.EQUALS, 'bar'))
    .orderBy(new SoqlSort(Account.CreatedDate, SoqlSort.Order.DESCENDING))
    .setRowLimit(100);
List<Account> accounts = (List<Account>) query.run();
```

> **Note:** You would be forgiven for confusing this example with [jOOQ](http://www.jooq.org/), a SQL query builder designed for use in Java. The `Soql` class was not directly inspired by jOOQ, but the query objects end up being created in a similar fashion. It bears noting that the method signatures differ since Apex reserves many of the keywords used in SOQL queries (i.e., `select`, `from`, `where`, etc).

#### **Methods**

The `Soql` class has methods which replicate every [SOQL function](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm) you can imagine, including:

-   `selectFields()`: Add field(s) to the `SELECT` clause.
-   `selectAll()`: Add all fields on the `FROM` SObjectType to the `SELECT` clause. Replicates `SELECT *` in Java.
-   `selectSubQuery()`: Add child `SubQuery` to the `SELECT` clause.
-   `selectAggregation`: Used in aggregate queries. Add a `SoqlAggregation` to the `SELECT` clause.
-   `fromSObject()`: Define the SObjectType/table that the query will be run against. This is also defined in the constructor.
-   `usingScope()`: Adds a `USING SCOPE` clause. See [**The `Soql.Scope` Enum**](#the-soql-scope-enum)for more.
-   `withExpression()`: Adds a `WITH` clause. Read more about `WITH` [here](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_enforce_usermode.htm) and [here](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_with_security_enforced.htm).
-   `whereFilters()`: Add filter(s) to the `WHERE` clause. See the [**`Filter`**](#the-filter-class) and [**`FilterLogic`**](#the-filter-logic-classs) Classes for more.
-   `setWhereLogic()`: Defines a `FilterLogic` class to be used to process the various filters in the `WHERE` clause.
-   `groupBy()`: Add field(s) to the `GROUP BY` clause.
-   `havingFilters()`: Used in aggregate queries. Adds `SoqlAggregation.AggregateFilter` object(s) to the `HAVING` clause.
-   `setHavingLogic()`: Used in aggregate queries. Defines the `FilterLogic` class to be used to process the various filters in the `HAVING` clause.
-   `orderBy()`: Set the `ORDER BY` field(s) and direction.
-   `setRowLimit()`: Set the `LIMIT` clause.
-   `setRowOffset()`: Set the `OFFSET` clause.
-   `forUsage()`: Set the `FOR` clause. See [**The `Soql.Usage` Enum**](#the-soql-usage-enum) for more.

### **Related Classes**

#### **The `Filter` Class**

The `Filter` class is used to produce an element of a SOQL `WHERE` clause.

Developers can construct a `Filter` object with the following parameters:

-   `field`/`fieldName` (`SObjectField`, `FieldRef`, `String`): The left-hand side of the `WHERE` statement.
-   `operator` (`Type`): The type of `Filter.Operator` to use as the operand. You can find a map of operator values and their corresponding symbols below.
-   `value` (`Object`): The expected result

```
Filter filter = new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000);
System.debug(filter);
// > "AnnualRevenue > 1000"
```

These filters can be added to a parent `Soql` query via the `whereFilters()` method:

```
Filter filter = new Filter(Account.AnnualRevenue, Filter.GREATER_THAN, 1000);
Soql query = DatabaseLayer.Soql.newQuery(Account).whereFilters(filter);
System.debug(query);
// > "SELECT Id FROM Account WHERE AnnualRevenue > 1000"
```

> **Note:** By default, multiple filters will be joined with "AND" statements. To define custom logic, pass a custom `FilterLogic` class to the query via the `setFilterLogic()` method.

The full list of `Filter.Operator` types and their corresponding symbols is as follows:

-   **EQUALS**: `=`
-   **NOT_EQUALS**: `!=`
-   **IN_COLLECTION**: `IN()`
-   **NOT_IN_COLLECTION**: `NOT IN()`
-   **GREATER_THAN**: `>`
-   **GREATER_OR_EQUAL**: `>=`
-   **LESS_THAN**: `<`
-   **LESS_OR_EQUAL**: `<=`
-   **STARTS_WITH**: `LIKE '%...'`
-   **NOT_STARTS_WITH**: `NOT LIKE '%...'`
-   **ENDS_WITH**: `LIKE '...%'`
-   **NOT_ENDS_WITH**: `NOT LIKE '...%'`
-   **CONTAINS**: `LIKE '%...%'`
-   **NOT_CONTAINS**: `NOT LIKE '%...%'`

Outside of the `Soql` class, the `Filter` class can be used to evaluate logical conditions via the `meetsCriteria()` method:

```
Account acc = new Account(AnnualRevenue = 999);
Filter filter = new Filter(
    Account.AnnualRevenue,
    Filter.LESS_THAN,
    1000
);
System.assert(true, filter.meetsCriteria(acc));
```

#### **The `FilterLogic` Class**

The `FilterLogic` abstract class wraps one or more `Filter` objects, and can be used to produce a complete SOQL `WHERE` clause.

The class has two inner implementations: `FilterLogic.AndLogic` and `FilterLogic.OrLogic`.

`AndLogic` is used to create a where clause where all conditions must be true:

```
FilterLogic logic = new FilterLogic.AndLogic()
    .addFilters(new Filter(
        Account.AnnualRevenue,
        Filter.GREATER_OR_EQUAL,
        1000
    )).addFilters(new Filter(
        Account.Name,
        Filter.CONTAINS,
        'Test'
    ));
System.debug(logic);
// > "AnnualRevenue >= 1000 AND Name LIKE '%Test%'"
```

`OrLogic` is used to create a `WHERE` clause where only one condition must be true:

```
FilterLogic logic = new FilterLogic.OrLogic()
    .addFilters(new Filter(
        Account.AnnualRevenue,
        Filter.GREATER_OR_EQUAL,
        1000
    )).addFilters(new Filter(
        Account.Name,
        Filter.CONTAINS,
        'Test'
    ));
System.debug(logic);
// > "AnnualRevenue >= 1000 OR Name LIKE '%Test%'"
```

If more complex conditional logic is required, developers can create their own `FilterLogic` implementation:

```
public class 2of3Logic extends FilterLogic {
    Filter filter1;
    Filter filter2;
    Filter filter3;

    public 2of3Logic(Filter filter1, Filter filter2, Filter filter3) {
        this.filter1 = filter1;
        this.filter2 = filter2;
        this.filter3 = filter3;
    }

    public override String toString() {
        // Any 2 conditions must be true
        return String.format(
            '(({0} AND {1}) OR ({0} AND {2}) OR ({1} AND {2}))',
            new List<String>{
                ownedByMe.toString(),
                highValue.toString(),
                inUSA.toString()
        });
    }
}
```

```
Filter filter1 = new Filter(Acount.AnnualRevenue, Filter.GREATER_THAN, 1000);
Filter filter2 = new Filter(Account.Custom__c, Filter.EQUALS, null);
Filter filter3 = new Filter(Account.Name, Filter.CONTAINS, 'Test');
FilterLogic logic = new 2of3Logic(filter1, filter2, filter3);
System.debug(logic);
/*
    "(AnnualRevenue > 1000 AND Custom__c = null) OR
    (AnnualRevenue > 100 AND Name LIKE '%Test%') OR
    (Custom__c = null AND Name LIKE '%Test%')"
*/
```

Outside of the `Soql` class, the `FilterLogic` class can be used to evaluate multiple logical conditions via the `meetsCriteria()` method:

```
Account acc = new Account(AnnualRevenue = 1000, Name = 'Test Acc');
FilterLogic logic = new FilterLogic.AndLogic()
    .addFilters(new Filter(
        Account.AnnualRevenue,
        Filter.GREATER_OR_EQUAL,
        1000
    )).addFilters(new Filter(
        Account.Name,
        Filter.CONTAINS,
        'Test'
    ));
System.assert(true, filter.meetsCriteria(acc));
```

#### **The `SoqlAggregation` Class**

The `SoqlAggregation` class represents an Aggregate Expression in SOQL.

Developers can construct a `SoqlAggregation` class using:

-   A `SoqlAggregate.Function` value, which enumerates the Aggregate Functions listed [here](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_agg_functions.htm).
-   A field, as defined by a `SObjectField` or `FieldRef` object.
-   An optional field alias (`String`).

```
SoqlAggregation agg = new SoqlAggregation(
    SoqlAggregation.COUNT,
    Account.Id,
    'numAccs'
);
System.debug(agg);
// > "COUNT(Id) numAccs"
```

These aggregations can be added to a parent `Soql` query via the `selectAggregation()` method:

```
SoqlAggregation agg = new SoqlAggregation(
    SoqlAggregation.COUNT,
    Account.Id,
    'numAccs'
);
Soql query = new Soql(Account.SObjectType).selectAggregation(agg);
System.debug(query);
// > "SELECT COUNT(Id) numAccs FROM Account"
```

#### **The `Soql.Scope` Enum**

The `Soql.Scope` enum includes all valid values for use with SOQL's `USING SCOPE` clause, including:

-   `DELEGATED`
-   `EVERYTHING`
-   `MINE`
-   `MINE_AND_MY_GROUPS`
-   `MY_TERRITORY`
-   `MY_TEAM_TERRITORY`
-   `TEAM`

Read more about `USING SCOPE` [here](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_using_scope.htm).

#### **The `SoqlSort` Class**

The `SoqlSort` class represents a SOQL `ORDER BY` clause. Developers can construct a `SoqlSort` object using the following parameters:

-   `field`/`fields` (`SObjectField`/`FieldRef`, or `List<SObjectField>`, `List<FieldRef>`): The field(s) that query results will be ordered by.
-   `order` (`SoqlSort.Order`): Determines the direction that query results will be sorted in. Possible values are `ASCENDING` and `DESCENDING`.
-   `nullOrder` (`SoqlSort.NullOrder`): (optional) Determines how null field values are factored in sorting. Possible values are `FIRST` and `LAST`.

```
SoqlSort sortBy = new SoqlSort(
    Account.Custom_Date__c,
    SoqlSort.Order.ASCENDING,
    SoqlSort.NullOrder.LAST
);
System.debug(sortBy);
// > "ORDER BY Custom_Date__c ASC NULLS LAST
```

This object can be added to a parent `Soql` query via the `orderBy()` method:

```
SoqlSort sortBy = new SoqlSort(
    Account.Custom_Date__c,
    SoqlSort.Order.ASCENDING
);
Soql query = DatabaseLayer.Soql.newQuery(Account.SObjectType).orderBy(sortBy);
System.debug(query);
// > "SELECT Id FROM Account ORDER BY Custom_Date__c ASC"
```

#### **The `Soql.Usage` Enum**

The `Soql.Usage` enum includes all valid values for use with SOQL's `FOR` clause, including:

-   `ALL_ROWS`
-   `FOR_VIEW`
-   `FOR_REFERENCE`
-   `FOR_UPDATE`

Read more [here](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_view.htm), [here](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_reference.htm), and [here](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_for_update.htm).

#### **The `SoqlWithClause` Class**

A `SoqlWithClause` is an abstract type that represents a [WITH filteringExpression](https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_with.htm).

It has two extending types, `ContextExpression` and `DataCategoryExpression`.

A `ContextExpression` is used to construct a `WITH` clause dealing with global filtering contexts. It accepts a `SoqlWithClause.Context` enum, and simply outputs that value:

```
SoqlWithClause.Context context = SoqlWithClause.Context.SECURITY_ENFORCED;
SoqlWithClause withClause = new SoqlWithClause.ContextExpression(context);
System.debug(withClause);'
// > "WITH SECURITY_ENFORCED"
```

A `DataCategoryExpression` accepts a `DataCategoryFilter.Logic` class. This class is used to construct a `WITH` clause dealing with Knowledge Data Categories. A `DataCategoryFilter.Logic` object can be comprised of one or many `DataCategoryFilter` objects.

A `DataCategoryFilter` object extends the `Filter` class, and accepts the following parameters:

-   `category` (`String`): The primary category to be compared against.
-   `operatorType` (`Type`): The type of `DataCategoryFilter.Operator` that is used to compare the primary category against the secondary category(ies).
-   `compareCategory`/`compareCategories` (`String`/`List<String>`): The secondary category(ies) to be compared against the primary category.

```
List<DataCategoryFilter> filters = new List<DataCategoryFilter>{
    new DataCategoryFilter('Category1', DataCategoryFilter.ABOVE, 'Category2'),
    new DataCategoryFilter('Category3', DataCategoryFilter.BELOW, new List<String>{
        'Category4',
        'Category5'
    })
};
FilterLogic logic = new DataCategoryFilter.AndLogic(filters);
System.debug(logic);
// > "Category1 ABOVE Category2 AND Category3 BELOW (Category4, Category5)"
```

These filters can be added to a parent `Soql` query via the `withExpresion()` method:

```
SoqlWithClause.Context context = SoqlWithClause.Context.SECURITY_ENFORCED;
SoqlWithClause withClause = new SoqlWithClause.ContextExpression(context);
Soql query = DatabaseLayer.Soql.newQuery(Account.SObjectType).withExpression(withClause);
System.debug(query);
// > "SELECT Id FROM Account WITH SECURITY_ENFORCED"
```

#### **The `SubQuery` Class**

The `SubQuery` class is used to create Child Relationship queries. These queries can be added to a parent `Soql` query via the `selectSubQuery()` method:

```
SubQuery oppsSubquery = new SubQuery(Opportunity.AccountId);
Soql query = DatabaseLayer.Soql.newQuery(Account.SObjectType).selectSubQuery(oppsSubquery);
System.debug(query);
// > "SELECT Id, (SELECT Id FROM Opportunities) FROM Account"
```

Developers can construct a `SubQuery` object using either:

-   The `SObjectField` on the child object that points to the parent object. The above example uses `Opportunity.AccountId` to get the `Account.Opportunities` child relationship.
-   The `Schema.ChildRelationship` that links the parent object to the child object. For example, `Account.Opportunities`. Unlike SObjectFields, this can't be directly referenced in Apex. Fortunately, this repository includes a method to easily get child relationship objects: `SchemaUtils.getChildRelationship(SObjectField lookupField)`.

The `SubQuery` class extends the `Soql` class, so all its methods are available for use. Unlike its parent class, the `fromSObject` will always return the `Schema.ChildRelationship` name, and the entire query will be wrapped in parentheses, ie., `(SELECT Id FROM My_Child_Objects__r)`.

### **Usage**

It's recommended that developers store queries as `Soql` objects in a `TestVisible` static variable for each class. This will allow each query to be extended and/or mocked if needed. Here's an example implementation:

```
public class AccountExporter {
    @TestVisible
    static Soql AccountQuery = DatabaseLayer.Soql.newQuery(Account.SObjectType);

    private Set<SObjectField> fields = new Set<SObjectField>();

    public AccountExporter addFields(SObjectField field) {
        this.fields.add(field);
        return this;
    }

    public HttpResponse export() {
        HttpRequest request = new HttpRequest();
        request.setBody(JSON.serialize(this.getAllAccounts()));
        request.setEndpoint('callout:My_External_System/accounts');
        request.setMethod('POST');
        return new Http().send(request);
    }

    @TestVisible
    private List<Account> getAllAccounts() {
        List<SObjectField> fieldList = new List<SObjectField>(this.fields);
        AccountQuery.selectFields(fieldList);
        return (List<Account>) AccountQuery.run();
    }
}
```

### **Mocking SOQL**

If you follow the recommended implementation pattern described in [**Usage**](#usage), mocking query objects is straightforward. Using the `AccountExporter` example from above:

```
@IsTest
static void testMocks() {
    // 1. Set the DatabaseLayer to handle mock DML & SOQL
    DatabaseLayer.setDmlEngine(new DmlMock());
    DatabaseLayer.setQueryEngine(new SoqlMock.Factory());
    // 2. Create mock data
    Account acc = new Account(Name = 'Test Account');
    List<Account> accList = new List<Account>{acc};
    DatabaseLayer.Dml.doInsert(accList);
    // 3. Inject mock data into the query's results
    AccountExporter.AccountQuery.toMock().setMockResults(accList);

    Test.startTest();
    List<Account> results = new AccountExporter().getAllAccounts();
    Test.stopTest();

    System.assertEquals(1, results?.size(), 'Wrong # of results');
    System.assertEquals(acc.Id, results[0].Id, 'Wrong Account returned');
}
```

Instead of returning actual database results, the query will return whatever is passed to it in `DmlMock.setMockResults()`. This gives developers the flexibility to test a variety of code paths without ever touching the actual database. As a result, test classes can be both incredibly thorough and lightning fast.
