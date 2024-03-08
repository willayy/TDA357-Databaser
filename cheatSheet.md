### SQL syntax
    JOIN <rows> ON <expression>
    LEFT JOIN <rows> ON <expression>
    RIGHT JOIN <rows> ON <expression>
    <query> UNION <query>
    <query> EXCEPT <query>
    SELECT A,B,C WHERE <expression> AND <expression> AND

    CREATE FUNCTION <name>() RETURNS TRIGGER AS $<name>$
        BEGIN
            <sql>
            RETURN <NEW/OLD>
        END
    $try_register$ LANGUAGE plpqsql

    CREATE TRIGGER <name> INSTEAD OF <INSERT/DELETE/UPDATE> ON <TABLE/VIEW>
        FOR EACH ROW EXECUTION function <name>()

    CASE
        WHEN EXISTS (
            <sql>
        ) THEN
            <sql>
        WHEN <expression>
            THEN
    END CASE

    If SUM() or COUNT() is used, GROUP BY is required.

    COALESCE(<expression>, <expression>) //

    CREATE VIEW <name> AS (
        <query>
    )
    
    WITH <name> AS (
        <query>
    )

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
        "required" : [
            "Property1",
            "Property2",
            "Property3"
        ]
        "properties" : {
            "Property1" : {
                "type": "string",
                "minLength": 10,
                "maxLength": 10,
                "title": "title1"
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
            }
        }
    }  

### Functional dependencies and Normal forms
Alternative sometimes complementary (to ER-diagram) way to derive a schema from a domain description. <br>

#### Definition

#### BCNF

##### Multivalued dependencies

### Relational algebra syntax