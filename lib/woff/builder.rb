module WOFF
  # Used in generation of WOFF files. Currently only modifies licensee
  # information and writes to a file. In the future it should stream
  # the output for use in one time use downloads.
  #
  #   woff = WOFF::Builder.new("/Users/Josh/Desktop/sample.woff")
  #   woff.font_with_licensee("The Friends")
  #
  class Builder
    def initialize(file)
      @location = file
    end

    def font_with_licensee_and_id(name, id)
      metadata_xml = ::Zlib::Inflate.inflate(data.metadata)
      metadata_doc = REXML::Document.new(metadata_xml)

      if metadata_doc.root.elements["licensee"]
        metadata_doc.root.elements["licensee"].attributes["name"] = name
      else
        metadata_doc.root.add_element "licensee", { "name" => name }
      end

      if metadata_doc.root.elements["license"]
        metadata_doc.root.elements["license"].attributes["id"] = id
      else
        metadata_doc.root.add_element "license", { "id" => id }
      end

      compressed_metadata = ::Zlib::Deflate.deflate(metadata_doc.to_s)

      data.meta_orig_length = metadata_doc.to_s.bytesize
      data.metadata = compressed_metadata
      data.meta_length = compressed_metadata.bytesize
      data.data_length = data.num_bytes

      data.to_binary_s
    end

    private
    attr_reader :location

    def data
      @data ||= WOFF::Data.read(File.open(location))
    end
  end
end
