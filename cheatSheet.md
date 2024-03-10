### SQL syntax
    JOIN <rows> ON <expression>
    LEFT JOIN <rows> ON <expression>
    RIGHT JOIN <rows> ON <expression>
    <query> UNION <query>
    <query> EXCEPT <query>
    SELECT A,B,C WHERE <expression> AND <expression> AND

    CREATE FUNCTION <name>() RETURNS TRIGGER AS $<name>$
        DECLARE <variable> INTEGER;
        BEGIN
            <sql>
            RETURN <NEW/OLD>
        END
    $try_register$ LANGUAGE plpqsql

    CREATE TRIGGER <name> INSTEAD OF <INSERT/DELETE/UPDATE> ON <TABLE/VIEW>
        FOR EACH ROW EXECUTION function <name>()

    BEFORE - the trigger is fired before the operation
    AFTER - the trigger is fired after the operation
    INSTEAD OF - the trigger is fired instead of the operation

    CASE
        WHEN EXISTS (
            <sql>
        ) THEN
            <sql>
        WHEN <expression>
            THEN
    END CASE

    If SUM() or COUNT() is used, GROUP BY is required.

    COALESCE(<expression>, <expression>)

    CREATE VIEW <name> AS (
        <query>
    )
    
    WITH <name> AS (
        <query>
    )

    SELECT DISTINCT <column> FROM <table>

    BEGIN;
        <sql>
    COMMIT;

    Can also be used with ROLLBACK; to undo changes made in the query.

    use HAVING instead of WHERE when using aggregate functions. For example:
        SELECT name, SUM(salary) FROM employee GROUP BY name HAVING SUM(salary) > 10000;

### ER diagram syntax
* #### Many-to-many relationships:
    "Students are registered to many courses" <br>
    entity -- relationship -- entity

* #### Many-to-exactly-one relationships:
    "Students are part of exactly on program" <br>
    entity -- relationship --) entity

* #### Many-to-at-most-one relationships:
    "A student can be part of a student branch" <br>
    entity -- relationship --> entity <br>
    can be made with ER-approach or Null-approach.

* #### Multiway relationships:
    "A course can have lectures with many roles and exactly one teacher per role" <br>

* #### Self-relationships:
    "Courses have other courses as prerequisites"

* #### Weak entities:
    "A student branch can be identified by which program it belongs to" <br>
    A entity which cant be identified with its own attributes is considered a weak entity.

* #### ISA relationships:
    "A course with limited positons ISA course" <br>
    Additional attribute relevant to ISA relationship is stored in another entity.


### JSON syntax
Best described with an example:

    {
        "title" : "JSON object title",
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
                        "Property3.1" : {
                            "type" : "string",
                        },
                        "Property3.2" : {
                            "type" : "string",
                        },
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

"type" can be "string", "number", "integer", "boolean", "object", "array", "null" <br>

{"$ref":"#/definitions/person"} is a reference to another object defined under "defintions in the JSON file<br>

### Functional dependencies and Normal forms
Alternative sometimes complementary (to ER-diagram) way to derive a schema from a domain description. <br>



#### Definition

#### BCNF

##### Multivalued dependencies

### Relational algebra syntax
'table' selects everything from the table <br>
π means select specific columns from a table <br>
(σ col1 = 'any' ('table')) is a condition <br>

π col1, col2 (σ col1 = 'any'(table)) <br>
is equal to select col1, col2 from table where col1 = 'any' <br>

→ is a AS for columns<br>
ρ is a AS for tables<br>

τ col1 means sort by col1 <br>
τ- col1 means sort by col1 in descending order <br>

τ col1 (π col1, col2 'table') <br>
is equal to select col1, col2 from table order by col1 <br>

δ is a distinct operator <br>
δ (π col1 'table') <br>

⨝ is a join operator <br>
⨝ OR is a outer right join <br>
⨝ OL is a outer left join <br>

δ(S ∪ R) is equal to S union R <br>
δ(S ∩ R) is equal to S intersect R <br>
δ(S - R) is equal to S except R <br>

γ is used with aggregate functions and group by <br>
γ col1, SUM(col2) 'table' <br>