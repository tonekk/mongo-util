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

      self.exec(cmd)
    end

    # Restore contents of @dump_dr to @to{database}
    # NOTE: Changes @to{database}
    def restore!
      unless @to[:host] && @to[:port] && @to[:db] && @from[:db]
        raise 'Cannot restore: needs @to[:host], @to[:port], @to[:db] & @from[:db]'
      end

      cmd = "mongorestore --host #{@to[:host]} --port #{@to[:port]} -d#{@to[:db]} dump/#{@from[:db]}"
      # Append auth, if neccessary
      cmd += Mongo::Util.authentication(@to)

      self.exec(cmd)
    end

    # Removes all items / items which match options[:query]
    # from collection of @from{database}
    # NOTE: Changes @from{database}
    def remove!(collection, options={})
      unless @to[:host] && @to[:port] && @to[:db]
        raise "Cannot remove #{collection}: needs @to[:host], @to[:port], @to[:db]"
      end

      cmd = "mongo #{@to[:db]} --host #{@to[:host]} --port #{@to[:port]}"
      # Append auth, if neccessary
      cmd += Mongo::Util.authentication(@to)
      cmd += " --eval 'db.#{collection}.remove(#{options[:query] ? options[:query].to_json : ""});'"

      self.exec(cmd)
    end

    # Returns Array of all collection-names of @from{database}
    def collections
      unless @from[:host] && @from[:port] && @from[:db]
        raise 'Cannot fetch collections: needs @to[:host], @to[:port], @to[:db]'
      end

      cmd = "mongo #{@from[:db]} --host #{@from[:host]} --port #{@from[:port]} --quiet --eval 'db.getCollectionNames()'"
      # Append auth, if neccessary
      cmd += Mongo::Util.authentication(@from)

      collections = self.exec(cmd, return_output: true).rstrip.split(',')
      # If we have a '{' in the output, Mongo has thrown an error
      collections.each {|col| raise "Error while fetching collections: '#{collections.join()}'" if col.include?('{')}
    end

    # Deletes @dump_dir
    def clean!
      self.exec("rm -rf #{@dump_dir}")
    end

    def exec(cmd, options={})
      # Print commands for debugging
      print "\n=======================================\n"
      print "| Executing: '#{cmd}'\n"
      print "=======================================\n\n"
      options[:return_output] ? `#{cmd}` : system(cmd)
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
