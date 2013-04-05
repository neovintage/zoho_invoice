module ZohoInvoice
  class Collection

    attr_reader :resource, :klass, :client

    def initialize(resource, client)
      @resource = resource
      @klass    = "ZohoInvoice::#{resource[0..-2].capitalize}".split('::').reduce(Module, :const_get)
      @client   = client
    end

    def search(*args, &block)
      @klass.search(@client, *args, &block)
    end

    def new(*args, &block)
      @klass.new(@client, *args, &block)
    end

    def create(*args, &block)
      @klass.create(@client, *args, &block)
    end

  end
end
