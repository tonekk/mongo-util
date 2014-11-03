require 'json'

module Mongo

  class Util

    STANDARD_TO_SETTINGS = { host: 'localhost', port: 27017 }

    attr_reader :from, :to
    attr_accessor :dump_dir

    def initialize(from={}, to={}, dump_dir=nil)
      @from = from
      @to = STANDARD_TO_SETTINGS.merge(to)
      @dump_dir = dump_dir || 'dump'
    end

    def from=(from)
      @from = @from.merge(from)
    end

    def to=(to)
      @to = @to.merge(to)
    end

    # Dump from @from{database}
    def dump(options={})
      unless @from[:host] && @from[:port] && @from[:db]
        raise 'Cannot dump: needs @to[:host], @port & @db'
      end

      cmd = "mongodump --host #{@from[:host]} --port #{@from[:port]} -d #{@from[:db]}"
      # Append collection, if neccessary
      cmd += " -c #{options[:collection]}" if options[:collection]
      # Append query, if neccessary
      cmd += " -q '#{options[:query].to_json}'" if options[:query]
      # Append auth, if neccessary
      cmd += Mongo::Util.authentication(@from)

      system(cmd)
    end

    # Restore contents of @dump_dr to @to{database}
    def restore
      unless @to[:host] && @to[:port] && @to[:db] && @from[:db]
        raise 'Cannot restore: needs @to[:host], @to[:port], @to[:db] & @from[:db]'
      end

      cmd = "mongorestore --host #{@to[:host]} --port #{@to[:port]} -d#{@to[:db]} dump/#{@from[:db]}"
      # Append auth, if neccessary
      cmd += Mongo::Util.authentication(@to)

      system(cmd)
    end

    # Removes all items / items which match options[:query]
    # from collection
    def remove(collection, options={})
      unless @to[:host] && @to[:port] && @to[:db]
        raise "Cannot remove #{collection}: needs @to[:host], @to[:port], @to[:db]"
      end

      cmd = "mongo #{@to[:db]} --host #{@to[:host]} --port #{@to[:port]}"
      # Append auth, if neccessary
      cmd += Mongo::Util.authentication(@to)
      cmd += " --eval 'db.#{collection}.remove(#{options[:query] ? options[:query].to_json : ""});'"

      system(cmd)
    end

    # Returns Array of all collection-names of @to{database}
    def collections
      unless @to[:host] && @to[:port] && @to[:db]
        raise 'Cannot fetch collections: needs @to[:host], @to[:port], @to[:db]'
      end

      cmd = "mongo #{@to[:db]} --host #{@to[:host]} --port #{@to[:port]} --quiet --eval 'db.getCollectionNames()'"
      # Append auth, if neccessary
      cmd += Mongo::Util.authentication(@to)

      `#{cmd}`.rstrip.split(',')
    end

    # Deletes @dump_dir
    def clean
      system("rm -rf #{@dump_dir}")
    end

    # Enable auth if we set db_config contains user & password
    def self.authentication(db_config)
      if (db_config[:user] && db_config[:password])
        " -u#{db_config[:user]} -p#{db_config[:password]}"
      else
        ""
      end
    end
  end
end
