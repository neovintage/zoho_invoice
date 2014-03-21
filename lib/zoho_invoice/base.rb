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

    def initialize(client, options = {})
      @client = client

      # Assign all of the single attribtues
      #
      if !self.attributes.blank?
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
      invoice_id = send("#{klass_name.downcase}_id")
      if(invoice_id.blank?)
        result = client.post("/api/v3/#{klass_name.downcase + 's'}", :JSONString => self.to_json)
      else
        result = client.put("/api/v3/#{klass_name.downcase + 's'}/#{invoice_id}", :JSONString => self.to_json)
      end
      if invoice_id.blank? && !result.body.blank? && !result.body[klass_name].blank?
        self.send("#{klass_name.downcase}_id=", result.body[klass_name.downcase]["#{klass_name.downcase}_id"])
      end
      self
    rescue Faraday::Error::ClientError => e
      if e.response && e.response[:body]
        raise ZohoInvoice::Error::ClientError.from_response(e.response)
      end
    end

    def to_json(*args)
      to_hash(*args).to_json
    end

    def to_hash(*args)
      build_attributes(ZohoInvoice::Invoice::CREATE_UPDATE_ATTRIBUTES)["#{self.class.to_s.split('::').last}"]
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

    def build_attributes(attrs)
      h = {}
      attrs.each do |attr|
        vals = self.send(attr)
#puts("VALS=$#{vals.to_s}$ ; TYPE=$#{vals.class.to_s}$ ; BLANK?=$#{vals.blank?}$ ; NIL?=$#{vals.nil?}$")
        if(vals.is_a?(Array) || vals.is_a?(Hash) || vals.is_a?(String))
          h["#{attr.to_s}"] = stringify_object_values(vals) unless(vals.blank?)
        else
          h["#{attr.to_s}"] = stringify_object_values(vals) unless(vals.nil?)
        end
      end
      self.reflections.each do |refl|
        refl_val = self.send(refl)
        if !refl_val.blank?
          refl_a = []
          refl_val.each {|r| refl_h << r}
          h[refl] = refl_a
        end
      end
      g = {}
      g[self.class.to_s.split('::').last] = h
      g
    end

    def stringify_object_values(obj)
raise("CATASTROPHY") if obj.nil?
puts("OBJ=$#{obj.to_s}$ ; TYPE=$#{obj.class.to_s}$ ; BLANK?=$#{obj.blank?}$ ; NIL?=$#{obj.nil?}$")
      return(obj.to_s.gsub(/[()\\"'\?\/]/, ' ').squeeze(' ').strip) unless(obj.is_a?(Array) || obj.is_a?(Hash))
      res = nil
      if(obj.is_a?(Array))
        res = []
        #obj.each {|elt| res << stringify_object_values(elt) if(((elt.is_a?(Array) || elt.is_a?(Hash) || elt.is_a?(String)) && !elt.blank?) || !elt.nil?)}
        obj.each do |elt|
puts("ELT=$#{elt.to_s}$ ; TYPE=$#{elt.class.to_s}$ ; BLANK?=$#{elt.blank?}$ ; NIL?=$#{elt.nil?}$ ; CONDITION=$#{(((elt.is_a?(Array) || elt.is_a?(Hash) || elt.is_a?(String)) && !elt.blank?) || !elt.nil?)}$")
          if(elt.is_a?(Array) || elt.is_a?(Hash) || elt.is_a?(String))
            res << stringify_object_values(elt) unless(elt.blank?)
          else
            res << stringify_object_values(elt) unless(elt.nil?)
          end
        end
      elsif(obj.is_a?(Hash))
        res = {}
        #obj.each {|key, elt| res[key] = stringify_object_values(elt) if(((elt.is_a?(Array) || elt.is_a?(Hash) || elt.is_a?(String)) && !elt.blank?) || !elt.nil?)}
        obj.each do |key, elt|
puts("ELT=$#{elt.to_s}$ ; TYPE=$#{elt.class.to_s}$ ; BLANK?=$#{elt.blank?}$ ; NIL?=$#{elt.nil?}$ ; CONDITION=$#{(((elt.is_a?(Array) || elt.is_a?(Hash) || elt.is_a?(String)) && !elt.blank?) || !elt.nil?)}$")
          if(elt.is_a?(Array) || elt.is_a?(Hash) || elt.is_a?(String))
            res << stringify_object_values(elt) unless(elt.blank?)
          else
            res << stringify_object_values(elt) unless(elt.nil?)
          end
        end
      end
      res
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
      if objects_to_hydrate.blank?
        return []
      else
        if objects_to_hydrate.is_a?(Hash) #Convert hash to array if only a single object is returned
          objects_to_hydrate = [objects_to_hydrate]
        end
        objects_to_hydrate.map do |result|
          new_hash = {}
          result.each do |key, value|
            new_hash[key.to_underscore.to_sym] = value
          end
          self.new(client, new_hash)
        end
      end
    end

  end
end
