# Bucardo

Ubuntu-based Bucardo image for Docker Containers.

### Contents
* [How to use it (plain-text passwords)](#how-to-use-it-plain-text-passwords)
* [How to use it (env-based passwords)](#how-to-use-it-env-based-passwords)
* [Acknowlegments](#acknowlegments)
* [Copyright and License](#copyright-and-license)

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
        "tables": "client",
        "onetimecopy": 1
      },{
        "sources": [1,2],
        "targets": [3],
        "tables": "product,order",
        "onetimecopy": 0
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

  * [Onetimecopy](https://bucardo.org/wiki/Onetimecopy) is used for full table copy:
    - 0 No full copy is done
    - 1 A full table copy is always performed
    - 2 A full copy is done in case the destination table is empty

4. Start the container:

  ```bash
  docker run --name my_own_bucardo_container \
    -v <bucardo.json dir>:/media/bucardo \
    -d plgr/bucardo
  ```

5. Check bucardo's status:

  ```bash
  docker logs my_own_bucardo_container -f
  ```

## How to use it (env-based passwords)

Same as before. The only difference is:

* In the JSON database definition, type "env" for password instead of the database user password;

* When you create a container, inform the password as a environment variable named *BUCARDO_DB<ID>*, where *ID* is the *ID* you defined earlier in the *bucardo.json*:

  ```bash
  docker run --name my_own_bucardo_container \
      -v <bucardo.json dir>:/media/bucardo \
      -e BUCARDO_DB3="secret" \
      -d plgr/bucardo
  ```

## Acknowlegments

This image uses the following software components:

* Ubuntu Xenial;
* PostgreSQL 9.5;
* Bucardo;
* JQ.

## Copyright and License

This project is copyright 2017 Lucas Vieira [lucas@vieira.io](mailto:lucas@vieira.io).<br />
Licensed under Apache 2.0 License.<br />
Check the license file for details.
