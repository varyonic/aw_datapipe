module AwDatapipe
  # A symbol table implemeted as a hash of objects keyed by their ids.
  class ObjectHash < Hash
    def initialize(*objects)
      super()
      self.append(*objects)
    end

    # Adds PipelineObjects to the symbol table
    # along with any of their dependencies.
    def append(*objects)
      objects.each { |object| self[object.id] = object }
      self
    end
    alias_method :<<, :append
  end
end
