module WOFF
  # Used in generation of WOFF files with modified metadata for licensee and
  # license id information.
  #
  #   woff = WOFF::Builder.new("/Users/Josh/Desktop/sample.woff")
  #   woff.font_with_licensee_and_id("The Friends", "L012356093901")
  #
  class Builder
    def initialize(file)
      @location = file
    end

    def font_with_licensee_and_id(name, id)
      metadata_xml = data.metadata.length > 0 ? compressor.inflate(data.metadata) : default_metadata
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

      compressed_metadata = compressor.deflate(metadata_doc.to_s)

      data.meta_orig_length = metadata_doc.to_s.bytesize
      data.metadata = compressed_metadata
      data.meta_length = compressed_metadata.bytesize
      data.meta_offset = data.metadata.abs_offset # "Offset to metadata block, from beginning of WOFF file."

      data.data_length = data.num_bytes

      data.to_binary_s
    end

    private
    attr_reader :location

    def data
      @data ||= WOFF::File.read(::File.open(location))
    end

    def compressor
      case data
      when WOFF::File::V1
        ::Zlib
      when WOFF::File::V2
        ::Brotli
      end
    end

    def default_metadata
      %Q{<?xml version="1.0" encoding="UTF-8"?><metadata version="1.0"></metadata>}
    end
  end
end
