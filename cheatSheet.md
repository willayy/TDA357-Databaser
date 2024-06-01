### SQL syntax

    JOIN <rows> ON <expression>
    LEFT JOIN <rows> ON <expression>
    RIGHT JOIN <rows> ON <expression>
    <query> UNION <query>
    <query> EXCEPT <query>
    SELECT A,B,C WHERE <expression> AND <expression> AND
    (can use =, !=, IN as expr)

    CREATE FUNCTION <name>() RETURNS TRIGGER AS $<name>$
        DECLARE <variable> INTEGER;
        BEGIN
            <sql>
            RETURN <NEW/OLD>
        END
    $<name>$ LANGUAGE plpqsql

    CREATE TRIGGER <name> INSTEAD OF <INSERT/DELETE/UPDATE> ON <TABLE/VIEW>
        FOR EACH ROW EXECUTION function <name>()

    BEFORE - the trigger is fired before the operation
    AFTER - the trigger is fired after the operation
    INSTEAD OF - the trigger is fired instead of the operation

    Order of operations SQL
    FROM
    WHERE
    GROUP BY
    HAVING
    SELECT 
    ORDER BY

    CASE
        WHEN EXISTS (
            <sql>
        ) THEN
            <sql>
        WHEN <expression>
            THEN
    END CASE

    If SUM() or COUNT() is used, GROUP BY is required. COUNT(*) will count all instance of GROUP BY <column>

    COALESCE(<expression>, <expression>)

    CREATE VIEW <name> AS (
        <query>
    )
    
    WITH <name> AS (
        <query>
    )

    CREATE TABLE <name> (
        <column> <type> PRIMARY KEY,
        <column> <type> UNIQUE,
        FOREIGN KEY (<column>) REFERENCES <table>(<column>)
        CHECK (<column> LIKE '______'),
        CHECK (<column> IN (1,2,3,...)),
        CHECK (<column> IS NULL OR <column> = "SomeStr")
    )

    INSERT INTO <table> (<column>) VALUES (<value>)

    SELECT DISTINCT <column> FROM <table>

    BEGIN;
        <sql>
    COMMIT;

    Can also be used with ROLLBACK; to undo changes made in the query.

    use HAVING instead of WHERE when using aggregate functions. For example:
        SELECT name, SUM(salary) FROM employee GROUP BY name HAVING SUM(salary) > 10000;
        
        SELECT name FROM EMPLOYEE GROUP BY name HAVING SUM(salary) > 10000;

### ER diagram syntax

Primary key is underlined witha filled line <br>
Secondary key is underlined with a dashed line <br>

-Many-to-many relationships- <br>
"Students are registered to many courses"
    entity -- relationship -- entity

-Many-to-exactly-one relationships- <br>
"Students are part of exactly on program"
    entity -- relationship --) entity

-Many-to-at-most-one relationships- <br>
"A student can be part of a student branch"
    entity -- relationship --> entity
    can be made with ER-approach or Null-approach.

-Multiway relationships- <br>
"A course can have lectures with many roles and exactly one teacher per role" <br>

-Self-relationships- <br>
"Courses have other courses as prerequisites"

-Weak entities- <br>
"A student branch can be identified by which program it belongs to" <br>
    A entity which cant be identified with its own attributes is considered a weak entity.

-ISA relationships- <br>
"A course with limited positons ISA course" <br>
    Additional attribute relevant to ISA relationship is stored in another entity.

### JSON

    {
        "title" : "TopLevelName", // for documentation only
        "type" : "object",
        "properties" : {
            "Property1" : {
                "type": "string",
                "minLength": 10,
                "maxLength": 10,
                "someThing" : {"enum" : ["value1", "value2"]}
            },
            "Property2" : {
                "anyOf":[{"type": "string"},{"type": "null"}],
            },
            "Property3" : {
                "type" : "array",
                "items" : {
                    "type" : "object",
                    "properties" : {
                        "Property31" : {
                            "type" : "string",
                        },
                        "Property32" : {
                            "type" : "string",
                        }
                    },
                },
                "maxItems" : 10
            }
        }
        "required" : [
            "Property1",
            "Property2",
            "Property3"
        ]
    }

-Valid JSON object-
    {
        "Property1": "value1",
        "Property2": null,
        "Property3": [
            {"Property31": "hello", "Property32": "world"},
            {"Property31": "foo", "Property32": "bar"}
        ]
    }

-JSONPath- <br>
"$.Property3[?(@.Property31 == 'Hello')].Property31" <br>
Searches for all property31 that are "Hello" <br>

"$.Property3[*].Property31" <br>
Searches for all property31 <br>

"$[?(@.SomeProperty == 'SomeValue')].someOtherProperty" <br>
Iterates through objects in array and finds the property someOtherProperty where SomeProperty is "someValue" <br>

-Types- <br>
"type" can be "string", "number", "integer", "boolean","object", "array", "null" <br>

-Definitions- <br>
{"$ref":"#/definitions/person"} is a reference to another object called person defined under "defintions" in the JSON file<br>

### Functional dependencies and Normal forms

Alternative sometimes complementary (to ER-diagram) way to derive a schema from a domain description. <br>

-Functional dependencies- <br>
X->A is a functional dependency iff for all attributes in a relation the elements in X uniquely determines the elements in A. <br>
a->b, a->c, same as a->b,c <br>
a->b, b->c, same as a->b,c <br>
a->b, b->c, c,d->e, = a,d->c,d,a = a,d->e (by transitivity and augmentation) <br>
a->a is a trivial functional dependency <br>
A functional dependency is in BCNF if the X is a superkey for the relation and its non trivial<br>

-Multivalued dependencies- <br>
A functional dependency is a multivalued dependency if the elements in X cant unqiuely determine the elements in A without being a trivial dependency. <br>
for example: course ->> teacher (a course can have many teachers) <br>

-Normalisation BCNF- <br>
Start with all attributes in on relation and use the found functional dependencies to break the relation into smaller relations. You stop when each relation has a functional dependency that is a superkey. When you break down a relation you leave the left side attributes in the relation and remove the right side attributes <br>

### Relational algebra syntax

'table' selects everything from the table <br>
π means select specific columns from a table <br>
(σ col1 = 'any' ('table')) is a conditional select <br>

→ is a AS for columns<br>
ρ is a AS for tables<br>

τ col1 means sort by col1 <br>
τ- col1 means sort by col1 in descending order <br>

δ is a distinct operator <br>
δ (π col1 'table') <br>

⨝ is a join operator <br>
⨝ OR is a outer right join <br>
⨝ OL is a outer left join <br>

δ(S ∪ R) is equal to S union R <br>
δ(S ∩ R) is equal to S intersect R <br>
δ(S - R) is equal to S except R <br>

γ is used with aggregate functions and group by <br>

#### Relational algebra examples

    γ col1, SUM(col2) 'table'
Select col1 and sum col2 group by col1 <br>

    π col1, col2 (σ col1 = 'any'(table))
Select col1, col2 from table where col1 = 'any' <br>

    τ col1 (π col1, col2 'table')
Select col1, col2 from table order by col1 <br>

    τ col11 (σ sum > 0 (γ col11, SUM(col12)→sum (table1 ⨝ col11 = col21 table2)))
Select col11, SUM(col12) as sum from table1 join table2 where sum > 0 group by col11 order by ascending col11 <br>

    τ− nrTables(γ waiter, COUNT(∗)→nrTables, SUM(nrGuests)→total (Sittings))
Select waiter, nrTables, total, from Sittings <br>