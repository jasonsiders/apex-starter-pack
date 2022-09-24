# Rollup

Rollup Summary fields are incredibly powerful for generating valuable business insights. Though "standard" Master-Detail rollups are somewhat limited, there's a number of tools on the AppExchange which empower admins to create their own custom rollups. Two of the most popular include [DLRS](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries) and [Rollup Helper](https://www.passagetechnology.com/rollup-helper-overview).

Early on in my career, our team used [Rollup Helper](https://www.passagetechnology.com/rollup-helper-overview). Because it was _so easy_ to add, the business would request new fields almost weekly, for use in various reports. For example:

-   `Average_Review_Score__c`: Displays the average of the `Score__c` field from all `CSAT_Review__c` records related to a `Contact`.

Unfortunately, our abuse of this tool eventually caught up with us. Our organization became plagued with all sorts of performance issues, especially Apex CPU Timeout and Row-Locking errors. After a bit of log analysis, it wasn't too hard to find out the culprit.

We worked hard to untangle ourselves from the mess we had created - eliminating any non-critical Rollup operations. Inevitably, there were some operations that could not be removed. To uninstall the app, we eventually created our own Rollup methods in Apex. This way, we at least had control over execution.

These methods worked, but they were themselves were inflexible and repetitive. Implementing (and testing!) new Rollup fields took ages.

I've since left that company, but haven't stopped thinking about ways to solve this problem. Enter the `Rollup` framework. `Rollup` handles the common logic behind all Rollup operations. Better yet, it automatically bulkifies, and be configured to run in a variety of contexts.

Developers can use its fluent interface to construct infinitely complex operations using just a couple of lines of code. In the future, Admins can also construct new rollup operations using no code at all via a Flow Action.

## Contents

-   [Creating a Rollup](#creating-a-rollup)
    -   [The `Rollup` Class](#the-rollup-class)
    -   [The `Rollup.RuntimeConfig` Class](#the-rollupruntime-config-class)
    -   [The `Rollup.Target` Class](#the-rolluptarget-class)
    -   [The `Rollup.Operation` Class](#the-rollupoperation-class)
    -   [The `Rollup.Calculator` Class](#the-rollupcalculator-class)]
    -   [The `ICriteria` Interface](#the-icriteria-interface)
-   [Usage](#usage)

## Creating a Rollup

`Rollup` uses a fluent architecture to maximize flexibility. Developers should familiarize themselves with the various objects that go into a rollup operation;

### **The `Rollup` Class**

A `Rollup` class represents a single execution of a Rollup method. It encompasses all of the following concepts - some of which are handled by inner types:

-   What rollup calculations will be run
-   On which records will rollup calculations be run
-   When will the rollup calculations run

Developers can construct a `Rollup` by providing it with a `Rollup.Target` object:

```
Rollup.Target target = new Rollup.Target(Account.SObjectType);
Rollup rollup = new Rollup(target);
```

The `Rollup.Target` object handles rollup calculation logic. See [The `Rollup.Target` Class](#the-rolluptarget-class) for more.

The `Rollup` class has 4 public methods, plus overrides:

-   `Rollup addRecords(Set<Id> recordIds/List<SObject> records)`: Adds target records to the Rollup for processing.
-   `Rollup addRecords(Set<Id> recordIds/List<SObject> records, SObjectField lookupField)`: Adds child records to the Rollup for processing. The `lookupField` specifies the link (lookup relationship) between the child objects and the desired target object.
-   `Rollup addOperation(SObjectField lookupField, Operation operation)`: Adds a `Rollup.Operation` object to the Rollup for processing. A `Rollup.Operation` object contains the logic needed to process a single rollup calculation. See [The `Rollup.Operation` Class](#the-rollupoperation-class) for more.
-   `Rollup setRuntime(RuntimeConfig runtime)`: Overrides the Rollup's default `Runtime.Config` object. The `Runtime.Config` class determines whether the rollup calculation will performed synchronously, or asynchronously through a Batch or Queueable job. This method is optional, and only needs to be call if the default implementation of `Rollup.RuntimeConfig` does not suit your needs. See [The `Rollup.RuntimeConfig` Class](#the-rollupruntimeconfig-class) for more.
-   `Id run()`: This method calculates the updated rollup values for the target records, and then submits them to be updated in the database. If the job was processed asynchronously, this method will return the Id of the asynchronous process. If the job was processed in real-time, `null` will be returned.

Here is an example rollup execution:

```
// 1. Build the rollup
Rollup rollup = new Rollup(new Target(Account.SObjectType))
    .addRecords(myAccountsVar)
    .addOperation(Opportunity.AccountId, new Rollup.Operation(
        Account.Number_of_Opportunities__c,
        new CountCalculator()
    ))
    .setRuntime(
        new Rollup.RuntimeConfig()
            .setExplicitContext(Runtime.Context.BATCHAPEX)
    );
// 2. Run the rollup
Id jobId = rollup.run();
```

### **The `Rollup.RuntimeConfig` Class**

The `Rollup.RuntimeConfig` class defines when a Rollup operation will be run. It extends the `Runtime` class.

By default, the RuntimeConfig class will allow the Rollup to process in real-time if a the number of records does not meet the defined `asyncThreshold`. Once this threshold is met, the RuntimeConfig class determines whether a `System.Queueable` or `Database.Batchable` job is needed to process the Rollup operation. It determines this based on a `batchThreshold` parameter.

This _elastic_ approach means that in most cases, developers don't need to worry about hitting limits, even with very large rollup operations. If needed, Developers may override this elastic framework and mandate that the Rollup always run in a specific context.

Developers may use the following methods to customize the `Rollup.RuntimeConfig`:

-   `Runtime setExplicitContext(Runtime.Context context)`: Overrides the elastic framework, and mandates that the Rollup be run in a specific context. See [The `Runtime.Context` Enum](#the-runtimecontext-enum) for more.
-   `Runtime setAsyncThreshold(Integer threshold)`: Defines the number of records required for a rollup transaction to be processed asynchronously. If the number of records does not exceed this amount, the rollup will be processed in real-time.
-   `Runtime setBatchSize(Integer batchSize)`: Defines the batch size of `Database.Batchable` rollup transactions.
-   `Runtime setBatchThreshold(Integer threshold)`: Defines the number of records required for an asynchronous rollup transaction to be processed via a `Database.Batchable` rollup. If the number of records does not exceed this amount, the rollup will be processed via a `System.Queueable` rollup.

The default values for the thresholds are as follows:

-   `asyncThreshold`: 100
-   `batchSize`: 200
-   `batchThreshold`: 200

#### **The `Runtime.Context` Enum**

The `Runtime.Context` enum defines specific execution contexts. `Rollup.RuntimeConfig` uses this enum to specify how the `Rollup` will be run.

Its values include:

-   `BATCHAPEX`
-   `QUEUEABLE`
-   `REAL_TIME`

### **The `Rollup.Target` Class**

The `Rollup.Target` class defines the rollup logic to take place. It specifies the target object that a Rollup will write to, as well as the child SObject relationship(s) that the Rollup will use to perform its calculations.

A `Rollup.Target` object can be constructed with an `SObjectType`:

```
Rollup.Target target = new Rollup.Target(Account.SObjectType);
```

Developers can add operations to the Target via the `addOperation` method:

```
Rollup.Target target = new Rollup.Target(Account.SObjectType)
    .addOperation(Opportunity.AccountId, new Operation(
        Account.Number_of_Opportunities__c,
        new CountCalculator()
    ));
```

> **Note:** For convenience, the `Rollup` class has its own `addOperation()` method, which calls its `target`'s `addOperation()` method.

If developers wish, they may execute a rollup without DML by calling the Target's `doRollup()` method directly:

```
Rollup.Target target = new Rollup.Target(Account.SObjectType)
    .addOperation(Opportunity.AccountId, new Operation(
        Account.Number_of_Opportunities__c,
        new CountCalculator()
    ));
List<SObject> results = target.process(myRecordsToRollup);
update results;
```

### **The `Rollup.Operation` Class**

A `Rollup.Operation` represents a single rollup calculation. A Rollup may have many `Rollup.Operation`s. For example, an Account may have fields for all of the following rollup operations:

-   `Num_Open_Cases__c`: A count of open Cases at any given time.
-   `Average_Satisfaction__c`: The average `Score__c` on all `Review__c` custom object records related to an Account.
-   `Total_Value__c`: A sum the `Amount` on all Closed Won Opportunities.
-   `Last_Activity__c`: The most recent `CreatedDate` of a Task.

All of these rollups may be configured with just a couple of lines of code:

```
Rollup.Target target = new Rollup.Target(Account.SObjectType)
    .addOperation(Case.AccountId, new Rollup.Operation(
        Account.Num_Open_Cases__c,
        new CountCalculator(),
        new Filter(Case.IsClosed, Filter.EQUALS, false)
    ))
    .addOperation(Review__c.Account__c, new Rollup.Operation(
        Account.Average_Satisfaction__c,
        new AvgCalculator().setCalcField(Review__c.Score__c)
    ))
    .addOperation(Opportunity.AccountId, new Operation(
        Account.Total_Value__c,
        new SumCalculator().setCalcField(Opportunity.Amount),
        new Filter(Opportunity.IsWon, Filter.EQUALS, true)
    ))
    .addOperation(Task.AccountId, new Operation(
        Account.Last_Activity__c,
        new MaxCalculator().setCalcField(Task.CreatedDate)
    ));
```

The `Rollup.Operation` class can be constructed with the following parameters:

-   `SObjectField targetField`: The field on the target object that calculation results will be written to.
-   `Rollup.Calculator calculator`: The `Rollup.Calculator` used to calculate the results for each record. See [The `Rollup.Calculator` Class](#the-rollupcalculator-class) for more.
-   `FilterLogic baseLogic`: (Optional) The base `FilterLogic` used to determine which child records will be used in the calculation. If none is given, defaults to an `AndLogic` instance. See [The `FilterLogic` Class](../DatabaseLayer/README.md/#the-filterlogic-class) for more.
-   `Filter filter`: (Optional) A single `Filter` object used to determine which child records will be used in the calculation. This filter gets added to the default `filterLogic` for the Operation, which is an `AndLogic` object.

```
Rollup.Operation op1 = new Rollup.Operation(
    Account.Number_of_Opps__c,
    new CountCalculator()
);
Rollup.Operation op2 = new Rollup.Operation(
    Account.Some_Other_Field__c,
    new CountCalculator(),
    new OrLogic()
);
Rollup.Operation op3 = new Rollup.Operation(
    Account.Another_Field__c,
    new AvgCalculator(),
    new Filter(Opportunity.IsWon, Filter.EQUALS, true)
);
```

Aside from its constructors, the `Rollup.Operation` class has just one public method: `addCriteria(ICriteria criteria)`. The method can be chained together to add multiple pieces of criteria.

```
Rollup.Operation operation = new Rollup.Operation(
    Account.Number_of_Opps__c,
    new AvgCalculator(),
    new OrLogic()
).addCriteria(new Filter(
    Opportunity.IsWon,
    Filter.EQUALS,
    true
)).addCriteria(new Filter(
    Opportunity.CloseDate,
    Filter.LESS_THAN,
    Date.today().addDays(-365)
));
```

See [The `ICriteria` Interface](../DatabaseLayer/README.md/#the-icriteria-interface) for more.

### **The `Rollup.Calculator` Class**

The `Rollup.Calculator` abstract class handles the calculation logic of a single Rollup operation.

A `Rollup.Calculator` cannot be directly constructed. You must construct an instance which extends it, like `SumCalculator`:

```
Rollup.Calculator calculator = new SumCalculator();
```

The `Rollup.Calculator` has three public methods:

-   `FieldRef getCalcField()`: returns the current `calcField`.
-   `Calculator setCalcField(SObjectField field/FieldRef fieldReference)`: Sets the current `calcField`, and returns the current instance. Callers can provide an `SObjectField` for simple field references, or a `FieldRef` object to refer to parent or grandparent fields on the target record.
-   `Object calculate(List<SObject> records)`: Run the calculation against a group of records, and returns the calculated value.

#### **Custom Calculators**

`Rollup` ships with the five most common calculation methods out of the box:

-   `AvgCalculator`
-   `CountCalculator`
-   `MaxCalculator`
-   `MinCalculator`
-   `SumCalculator`

However, the `Rollup.Calculator` class can be extended to suit your own custom calculation logic. When building your own custom type, you may override any of these virtual methods:

-   `Calculator setCalcField(SObjectField field)`: Default implementation sets the current `calcField`, and returns the current instance. Nearly all `Calculator` objects will use the default implementation. However, The `CountCalculator` does not, since a `calcField` is not needed to count the number of records.
-   `Object calculate(List<SObject> records)`: Default implementation runs the calculation against a group of records, and returns the calculated value.
-   `Boolean calculateBoolean(List<SObject> records)`: A sub-method called by `calculate()` when the `calcField` is a `Boolean` value.
-   `Date calculateDate(List<SObject> records)`: A sub-method called by `calculate()` when the `calcField` is a `Date` value.
-   `DateTime calculateDateTime(List<SObject> records)`: A sub-method called by `calculate()` when the `calcField` is a `DateTime` value.
-   `Decimal calculateNumber(List<SObject> records)`: A sub-method called by `calculate()` when the `calcField` is an `Integer`/`Decimal` value.
-   `String calculateText(List<SObject> records)`: A sub-method called by `calculate()` when the `calcField` is a `String` value.

Here is an example of a custom `Rollup.Calculator`, which calculates the "reverse-sum" from the given `calcField`:

```
public class ReverseSumCalculator extends Rollup.Calculator {
    // Returns the SUM of Positive Numbers as a negative
    public override Decimal calculateNumber(List<SObject> records) {
        Decimal sum = 0;
        for (SObject record : records) {
            SObjectField calcField = this.getCalcField?.toSchemaType();
            Decimal recordValue = (Decimal) record?.get(calcField);
            Decimal sumValue = (recordValue != null) ? recordValue : 0;
            sum -= sumValue;
        }
        return sum;
    }
}
```

```
Rollup.Operation moneyLost = new Rollup.Operation(
    Account.Money_Lost__c,
    new ReverseSumCalculator().setCalcField(Opportunity.Amount),
    new Filter(Opportunity.IsLost, Filter.EQUALS, true)
);
```

### **The `ICriteria` Interface**

The `ICriteria` interface was originally designed for use in `Soql`, but it has its own built-in methods to determine if SObjects meet its defined criteria:

```
// The `Filter` class is one type that implements ICriteria:
ICriteria filter = new Filter(
    Account.Name,
    Filter.CONTAINS,
    'Test'
);
Account account = new Account(Name = 'My Test Account');
Boolean isTest = filter.meetsCriteria(account);
// > true
```

In `Rollup`, `ICriteria` objects are used as part of the `Rollup.Request` class to remove certain records from the calculation.

In this example, a `Filter` object is applied to ensure that only "Closed Won" Opportunities are summed:

```
Rollup.Request totalValue = new Rollup.Request(
    Account.Total_Value__c,
    new SumCalculator().setCalcField(Opportunity.Amount),
    new Filter(Opportunity.IsWon, Filter.EQUALS, true)
);
```

You can read more about the `ICriteria` interface [here](../DatabaseLayer/README.md/#the-icriteria-interface);

## Usage

Developers can use `Rollup`'s fluent interface to constrcut complex rollup operations using just a couple of lines of code:

```
Rollup rollup = new Rollup(new Rollup.Target(Account.SObjectType))
    .addOperation(Case.AccountId, new Rollup.Operation(
        Account.Num_Open_Cases__c,
        new CountCalculator(),
        new Filter(Case.IsClosed, Filter.EQUALS, false)
    ))
    .addOperation(Review__c.Account__c, new Rollup.Operation(
        Account.Average_Satisfaction__c,
        new AvgCalculator().setCalcField(Review__c.Score__c)
    ))
    .addOperation(Opportunity.AccountId, new Operation(
        Account.Total_Value__c,
        new SumCalculator().setCalcField(Opportunity.Amount),
        new Filter(Opportunity.IsWon, Filter.EQUALS, true)
    ))
    .addOperation(Task.AccountId, new Operation(
        Account.Last_Activity__c,
        new MaxCalculator().setCalcField(Task.CreatedDate)
    ));
```

Once constructed, developers may run a rollup through its `run()` method:

```
Id jobId = rollup.run();
```

The `run()` method will automatically choose the optimal execution context for the operation. Depending on the number of records and other limits, it will process the rollup in real-time, or asynchronously via a `System.Queueable` job, or a `Database.Batchable` job.

If developers wish to force a specific execution context, they may do so through the `Rollup.RuntimeConfig`'s `setExplicitContext()` method:

```
Rollup.RuntimeConfig config = new Rollup.RuntimeConfig()
    .setExplicitContext(Runtime.Context.BATCHAPEX);
rollup.setRuntime(config);
```

Alternatively, developers may create a `Database.Batchable` or `System.Queueable` instance of the `Rollup` manually:

```
Database.executeBatch(rollup, 200);
System.enqueueJob(rollup, 200);
```
