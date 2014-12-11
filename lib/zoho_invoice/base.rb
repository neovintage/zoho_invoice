module ZohoInvoice
  # Used for instances when some of the representations in zoho
  # dont have their own end points in the API
  #
  class ActionNotSupportedError < StandardError; end

  class Base

    attr_reader :client

    def self.define_object_attrs(*attrs)
      @attributes = attrs
      create_attributes(attrs)
    end

    # TODO Create an Association class to manage the relationship
    #
    def self.has_many(*attrs)
      @reflections = attrs
      create_attributes(attrs)
    end

    def self.create(client, options = {})
      self.new(client, options).save
    end

    # TODO need to build a class that is something like ActiveRecord::Relation
    # TODO need to be able to handle associations when hydrating objects
    #
    def self.search(client, input_text, options = {})
      result_hash = client.get("/api/view/search/#{self.to_s.split('::').last.downcase}s", :searchtext => input_text).body
      objects_to_hydrate = result_hash['Response']["#{self.to_s.split('::').last}s"]["#{self.to_s.split('::').last}"]
      self.process_objects(client, objects_to_hydrate)
    rescue Faraday::Error::ClientError => e
      if e.response[:body]
        raise ZohoInvoice::Error::ClientError.from_response(e.response)
      end
    end

    def initialize(client, options = {})
      @client = client

      # Assign all of the single attribtues
      #
      if !self.attributes.empty?
        (self.attributes & options.keys).each do |attribute|
          self.send("#{attribute}=", options[attribute])
        end
      end

      # Assign all of the associations.  Not the most advanced
      #
      if self.reflections.is_a?(Array)
        self.reflections.each { |r| self.send("#{r}=", []) }
        (self.reflections & options.keys).each do |reflection|
          options[reflection].each do |reflection_obj|
            klass = ZohoInvoice.const_get(camel_case(reflection.to_s[0..-2]))
            if reflection_obj.is_a?(Hash)
              self.send("#{reflection}") << klass.new(@client, reflection_obj)
            elsif reflection_obj.is_a?(klass)
              self.send("#{reflection}") << reflection_obj
            end
          end
        end
      end
    end

    def reflections
      self.class.instance_variable_get(:'@reflections') || []
    end

    def attributes
      self.class.instance_variable_get(:'@attributes') || []
    end

    # TODO Determining the resource to use will need to change
    #
    def save
      klass_name = self.class.to_s.split('::').last

      action = 'create'
      action = 'update' if !send("#{klass_name.downcase}_id").nil?

      result = client.post("/api/#{klass_name.downcase + 's'}/#{action}", :XMLString => self.to_xml)

      if action == 'create' && !result.body.nil? && !result.body['Response'][klass_name].nil?
        self.send("#{klass_name.downcase}_id=", result.body['Response'][klass_name]["#{klass_name}ID"])
      end

      self
    rescue Faraday::Error::ClientError => e
      if e.response[:body]
        raise ZohoInvoice::Error::ClientError.from_response(e.response)
      end
    end

    def self.create_attributes(attrs)
      attrs.each do |attr|
        attr_accessor attr
      end
    end

  protected

    def self.camel_case(str)
      return str if str !~ /_/ && str =~ /[A-Z]+.*/
      str.split('_').map do |e|
        if e == "id"
          e.upcase
        else
          e.capitalize
        end
      end.join
    end

    def camel_case(str)
      self.class.camel_case(str)
    end

  end
end
