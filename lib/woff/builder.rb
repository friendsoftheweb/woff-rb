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
      font_with_metadata(licensee: name, license_id: id)
    end

    def font_with_metadata(licensee: nil, license_id: nil, license_text: nil, description: nil)
      metadata_xml = data.metadata.length > 0 ? compressor.inflate(data.metadata) : default_metadata
      metadata_doc = REXML::Document.new(metadata_xml)

      if licensee
        if metadata_doc.root.elements["licensee"]
          metadata_doc.root.elements["licensee"].attributes["name"] = licensee
        else
          metadata_doc.root.add_element "licensee", { "name" => licensee }
        end
      end

      if license_id
        if metadata_doc.root.elements["license"]
          metadata_doc.root.elements["license"].attributes["id"] = license_id
        else
          metadata_doc.root.add_element "license", { "id" => license_id }
        end
      end

      if license_text
        license_el = metadata_doc.root.elements["license"]
        unless license_el
          license_el = metadata_doc.root.add_element "license"
        end

        license_text_el = license_el.elements["text"]
        unless license_text_el
          license_text_el = license_el.add_element("text", { "lang" => "en "})
        end

        license_text_el.text = license_text
      end

      if description
        description_el = metadata_doc.root.elements["description"]
        unless description_el
          description_el = metadata_doc.root.add_element "description"
        end

        description_text_el = description_el.elements["text"]
        unless description_text_el
          description_text_el = description_el.add_element("text", { "lang" => "en "})
        end

        description_text_el.text = description
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
