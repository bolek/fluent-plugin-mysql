# fluent-plugin-mysql-simple-json
Heavily based on: TAGOMORI Satoshi mysql plugin - https://github.com/tagomoris/fluent-plugin-mysql

## Component

### MysqlOutput

[Fluentd](http://fluentd.org) plugin to store events in mysql tables over SQL.
The target table is expected to have the following schema:

```sql
CREATE TABLE IF NOT EXISTS events (
  tag varchar(255),
  at timestamp,
  received_at timestamp,
  payload longtext)
```

If the event record has a "at" key, this value will be inserted into the `at`columns. Otherwise fluentd event timestamp will be used.

## Configuration

### MysqlOutput

MysqlOutput needs MySQL server's host/port/database/username/password, and INSERT format as SQL, or as table name and columns.

    <match output.by.sql.*>
      type mysql
      host master.db.service.local
      # port 3306 # default
      database application_logs
      username myuser
      password mypass
      flush_interval 5s
    </match>

    <match output.by.names.*>
      type mysql
      host master.db.service.local
      database application_logs
      username myuser
      password mypass
      table accesslog
      flush_interval 5s
    </match>

To include time/tag into output, use `include_time_key` and `include_tag_key`, like this:

Or, for json:

    <match output.with.tag.and.time.as.json.*>
      type mysql
      host database.local
      database foo
      username root

      include_time_key yes
      utc   # with UTC timezone output (default: localtime)
      time_format %Y%m%d-%H%M%S
      time_key timeattr

      include_tag_key yes
      tag_key tagattr
      table accesslog
    </match>
    #=> inserted json data into column 'jsondata' with addtional attribute 'timeattr' and 'tagattr'

## Prerequisites

`fluent-plugin-mysql-simple-json` uses `mysql2` gem, and `mysql2` links against `libmysqlclient`. See [Installing](https://github.com/brianmario/mysql2#installing) for its installation.

## Copyright

* Copyright
  * Copyright(C) 2012- TAGOMORI Satoshi (tagomoris)
* License
  * Apache License, Version 2.0
