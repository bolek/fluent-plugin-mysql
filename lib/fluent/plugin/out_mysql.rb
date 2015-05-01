class Fluent::MysqlOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output("mysql", self)

  include Fluent::SetTimeKeyMixin
  include Fluent::SetTagKeyMixin

  config_param :host, :string
  config_param :port, :integer, default: nil
  config_param :database, :string
  config_param :username, :string
  config_param :password, :string, default: ""

  config_param :table, :string, default: nil

  attr_accessor :handler, :sql

  def initialize
    super
    require "mysql2-cs-bind"
  end

  # Define `log` method for v0.10.42 or earlier
  define_method("log") { $log } unless method_defined?(:log)

  def configure(conf)
    super

    @sql = "INSERT INTO #{@table} (tag,logged_at,occured_at,payload) VALUES (?,?,?,?)"
    @format_proc = proc do |tag, time, record|
      at = record["occured_at"] ? record["occured_at"] : Time.at(time).utc.strftime("%Y-%m-%d %H:%M:%S")
      [tag, Time.at(time).utc.strftime("%Y-%m-%d %H:%M:%S"), at, record.to_json]
    end
  end

  def start
    super
  end

  def shutdown
    super
  end

  def format(tag, time, record)
    [tag, time, @format_proc.call(tag, time, record)].to_msgpack
  end

  def client
    Mysql2::Client.new(
      host: @host, port: @port,
      username: @username, password: @password,
      database: @database, flags: Mysql2::Client::MULTI_STATEMENTS
    )
  end

  def write(chunk)
    handler = client
    chunk.msgpack_each { |tag, time, data| handler.xquery(@sql, data) }
    handler.close
  end
end
