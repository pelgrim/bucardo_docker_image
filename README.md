# Bucardo
##### Lucas' Docker Container

Ubuntu-based Bucardo container.

### Contents
* [How to use it (plain-text passwords)]
* [How to use it (env-based passwords)]
* [How it works]
* [Acknowlegment]

---

## How to use it (plain-text passwords)

1. Create a folder;

2. Create a "bucardo.json" inside this folder;

3. Fill the "bucardo.json" file following this example:

  ```json
  // bucardo.json

  {
    "databases":[
      {
        "id": 3,
        "dbname": "example_db",
        "host": "host0.example.com",
        "user": "example_user",
        "pass": "secret"
      },{
        "id": 1,
        "dbname": "example_db",
        "host": "host1.example.com",
        "user": "example_user",
        "pass": "secret"
      },{
        "id": 2,
        "dbname": "example_db",
        "host": "host3.example.com",
        "user": "example_user",
        "pass": "secret"
      }],
    "syncs" : [
      {
        "sources": [3],
        "targets": [1,2],
        "tables": "client"
      },{
        "sources": [1,2],
        "targets": [3],
        "tables": "product, order"
      }
    ]
  }
  ```

  * Inside databases, describe all databases you desire to sync as a source and/or as a target;

  * The *ID* attribute must be a unique integer per database, and has nothing to do your database but the way the container will identify it;

  * Once your databases are described, you must describe your *syncs*;

  * Each sync must have one or more *sources*, and one or more *targets*; and these have to be described following JSON standard Array notation;

  * Each entity inside the *sources* and *targets* arrays represents an *ID* referring to the databases described beforehand;

  * The other attribute required is the syncs' *table lists*. A *table list* is a String containing the tables sync'd by that sync, separated by a comma and a space, as in the example above.

4. Start the container with a command such as:

  ```bash
  docker run --name my_own_bucardo_container \
    -v <bucardo.json dir>:/media/bucardo \
    -it plgr/bucardo
  ```

And that's that. If you run a <code>docker attach my_own_bucardo_container</code>, you will be able to watch the current status of your bucardo syncs.

## How to use it (env-based passwords)

## How it works

## Acknowlegment
