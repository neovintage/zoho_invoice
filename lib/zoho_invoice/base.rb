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

    #<AlexSherstinsky>Commenting this out, since "search" does not seem to exist in the V3 API version..</AlexSherstinsky>
    ## TODO need to build a class that is something like ActiveRecord::Relation
    ## TODO need to be able to handle associations when hydrating objects
    ##
    #def self.search(client, input_text, options = {})
    #  result_hash = client.get("/api/v3/view/search/#{self.to_s.split('::').last.downcase}s", :searchtext => input_text).body
    #  objects_to_hydrate = result_hash['Response']["#{self.to_s.split('::').last}s"]["#{self.to_s.split('::').last}"]
    #  self.process_objects(client, objects_to_hydrate)
    #rescue Faraday::Error::ClientError => e
    #  if e.response && e.response[:body]
    #    raise ZohoInvoice::Error::ClientError.from_response(e.response)
    #  end
    #end

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

      #<AlexSherstinsky>The response data in V3 API version is JSON.</AlexSherstinsky>
      #result = client.post("/api/v3/#{klass_name.downcase + 's'}/#{action}", :XMLString => self.to_xml)
      result = client.post("/api/v3/#{klass_name.downcase + 's'}/#{action}", :JSONString => self.to_json)

      #if action == 'create' && !result.body.nil? && !result.body['Response'][klass_name].nil?
      if action == 'create' && !result.body.nil? && !result.body[klass_name].nil?
        #self.send("#{klass_name.downcase}_id=", result.body['Response'][klass_name]["#{klass_name}ID"])
        self.send("#{klass_name.downcase}_id=", result.body[klass_name]["#{klass_name}ID"])
      end

      self
    rescue Faraday::Error::ClientError => e
      if e.response && e.response[:body]
        raise ZohoInvoice::Error::ClientError.from_response(e.response)
      end
    end

    # This needs to be a Nokogiri::XML::Builder
    #
    def to_xml(*args)
      build_attributes.to_xml(*args)
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

    def build_attributes
      Nokogiri::XML::Builder.new do |xml|
        xml.send("#{self.class.to_s.split('::').last}") {
          self.attributes.each do |attr|
            vals = self.send(attr)
            if !vals.nil? && !vals.is_a?(Array)
              xml.send("#{camel_case(attr.to_s)}_", self.send(attr))
            end
          end
          self.reflections.each do |refl|
            if !refl.empty?
              xml.send(camel_case(refl.to_s)) {
                self.send(refl).each { |x| xml << x.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::NO_DECLARATION) }
              }
            end
          end
        }
      end
    end

    private

    def self.retrieve(client, url, plural = true)
      klass_name = self.to_s.split('::').last.downcase
      klass_name += 's' if(plural)
      page = 1
      query = {}
      objects_to_hydrate = []

      begin
        result_hash = client.get(url, query).body
        potential_objects = result_hash

        if potential_objects
          potential_objects = potential_objects[klass_name]
          if potential_objects.is_a? Hash
            potential_objects = [potential_objects]
          end
          objects_to_hydrate += potential_objects
        end

        page_context = result_hash['page_context']
        if page_context
          has_more_page = page_context['has_more_page']
          if(has_more_page)
            page += 1
            query = { :page => page }
          end
        else
          has_more_page = false
        end
      end while has_more_page

      self.process_objects(client, objects_to_hydrate)
    rescue Faraday::Error::ClientError => e
      if e.response && e.response[:body]
        raise ZohoInvoice::Error::ClientError.from_response(e.response)
      end
    end

    def self.process_objects(client, objects_to_hydrate)
      if objects_to_hydrate.nil?
        return []
      else
        if objects_to_hydrate.is_a?(Hash) #Convert hash to array if only a single object is returned
          objects_to_hydrate = [objects_to_hydrate]
        end
        objects_to_hydrate.map do |result|
          new_hash = {}
          result.each do |key, value|
            #<AlexSherstinsky>Since the response data in V3 API version is JSON, it is acceptable (and desirable) to allow Hash and Array field values.</AlexSherstinsky>
            #new_hash[key.to_underscore.to_sym] = value if !value.is_a?(Hash) && !value.is_a?(Array)
            new_hash[key.to_underscore.to_sym] = value
          end
          self.new(client, new_hash)
        end
      end
    end

  end
end
