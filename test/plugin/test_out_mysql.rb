require "helper"
require "mysql2-cs-bind"

class MysqlOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    host db.local
    database testing
    username testuser
    sql INSERT INTO tbl SET jsondata=?
    format json
  ]

  def create_driver(conf = CONFIG, tag = "test")
    d = Fluent::Test::BufferedOutputTestDriver.new(Fluent::MysqlOutput, tag).configure(conf)
    d.instance.instance_eval {
      def client
        obj = Object.new
        obj.instance_eval {
          def xquery(*args); [1]; end
          def close; true; end
        }
        obj
      end
    }
    d
  end

  def test_configure
    d = create_driver %[
      host database.local
      database foo
      username bar
      table baz
    ]
    assert_equal "INSERT INTO baz (tag,logged_at,occured_at,payload) VALUES (?,?,?,?)", d.instance.sql
  end

  def test_format
    d = create_driver

    time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    d.emit({ "a" => 1 }, time)
    d.emit({ "a" => 2 }, time)

    d.expect_format ["test", time, ["test", Time.at(time).utc.strftime("%Y-%m-%d %H:%M:%S"), Time.at(time).utc.strftime("%Y-%m-%d %H:%M:%S"), { "a" => 1 }.to_json]].to_msgpack
    d.expect_format ["test", time, ["test", Time.at(time).utc.strftime("%Y-%m-%d %H:%M:%S"), Time.at(time).utc.strftime("%Y-%m-%d %H:%M:%S"), { "a" => 2 }.to_json]].to_msgpack

    d.run
  end

  def test_json
    d = create_driver %[
      host database.local
      database foo
      username bar
      password mogera
      utc
      table accesslog
    ]
    assert_equal "INSERT INTO accesslog (tag,logged_at,occured_at,payload) VALUES (?,?,?,?)", d.instance.sql

    time = Time.parse("2012-12-17 09:23:45 +0900").to_i # JST(+0900)
    record = { "field1" => "value1" }
    d.emit(record, time)

    d.expect_format ["test", time, ["test", Time.at(time).utc.strftime("%Y-%m-%d %H:%M:%S"), Time.at(time).utc.strftime("%Y-%m-%d %H:%M:%S"), record.to_json]].to_msgpack
    d.run
  end

  def test_json_with_at_field
    d = create_driver %[
      host database.local
      database foo
      username bar
      password mogera
      utc
      table accesslog
    ]
    assert_equal "INSERT INTO accesslog (tag,logged_at,occured_at,payload) VALUES (?,?,?,?)", d.instance.sql

    time = Time.parse("2012-12-17 09:23:45 +0900").to_i # JST(+0900)
    record = { "field1" => "value1", "occured_at" => "2010-11-10 00:23:45" }
    d.emit(record, time)

    d.expect_format ["test", time, ["test", Time.at(time).utc.strftime("%Y-%m-%d %H:%M:%S"), "2010-11-10 00:23:45", record.to_json]].to_msgpack
    d.run
  end

  def test_write
    # hmm...
  end
end
