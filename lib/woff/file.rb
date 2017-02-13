class UIntBase128 < BinData::BasePrimitive
  # TODO: This should, like actually encode the value. This file might help:
  # https://github.com/khaledhosny/woff2/blob/f43ad222715f58ea62a004b54e4b6a31e589e762/src/variable_length.cc
  def value_to_binary_string(value)
    "0"
  end

  def read_and_return_value(io)
    value = 0
    offset = 0

    loop do
      byte = io.readbytes(1).unpack('C')[0]
      value |= (byte & 0x7F) << offset
      offset += 7
      if byte & 0x80 == 0
        break
      end
    end

    value
  end

  def sensible_default
    0
  end
end

module WOFF
  class File
    def self.read(file)
      data = Data.read(file)
      file.rewind

      if data.signature == 0x774F4646
        V1.read(file)
      elsif data.signature == 0x774F4632
        V2.read(file)
      else
        raise WOFF::InvalidSignatureError
      end
    end

    class Data < ::BinData::Record
      endian :big

      uint32 :signature
    end

    class V1 < ::BinData::Record
      endian :big
      count_bytes_remaining :bytes_remaining

      uint32 :signature
      uint32 :flavor
      uint32 :data_length
      uint16 :num_tables
      uint16 :reserved
      uint32 :total_s_fnt_size
      uint16 :major_version
      uint16 :minor_version
      uint32 :meta_offset
      uint32 :meta_length
      uint32 :meta_orig_length
      uint32 :priv_offset
      uint32 :priv_length

      array :table_directory, initial_length: :num_tables do
        uint32 :tag
        uint32 :table_offset
        uint32 :comp_length
        uint32 :orig_length
        uint32 :orig_checksum
      end

      string :fonts, read_length: lambda {
        dir = table_directory.sort_by { |entry| entry["table_offset"] }

        first_table_start = dir.first["table_offset"]
        last_table_end = dir.last["table_offset"] + dir.last["comp_length"]

        table_length = last_table_end - first_table_start

        # Next largest number divisible by 4
        (table_length / 4.0).ceil * 4
      }

      string :metadata, read_length: :meta_length

      rest :private_data
    end


    class V2 < ::BinData::Record
      endian :big
      count_bytes_remaining :bytes_remaining

      uint32 :signature
      uint32 :flavor
      uint32 :data_length
      uint16 :num_tables
      uint16 :reserved
      uint32 :total_s_fnt_size
      uint32 :total_compressed_size
      uint16 :major_version
      uint16 :minor_version
      uint32 :meta_offset
      uint32 :meta_length
      uint32 :meta_orig_length
      uint32 :priv_offset
      uint32 :priv_length

      array :table_directory, initial_length: :num_tables do
        uint8 :flags
        uint32 :tag, onlyif: -> {
          bits = flags.to_binary_s.unpack('B*')[0]
          tag_index = bits[0..5].to_i(2)

          tag_index == 63
        }
        u_int_base128 :orig_length
        u_int_base128 :transform_length, onlyif: -> {
          bits = flags.to_binary_s.unpack('B*')[0]
          tag_index = bits[0..5].to_i(2)
          transform_version = bits[6..7].to_i(2)
          is_loca_or_glyf = [10, 11].include?(tag_index)

          (is_loca_or_glyf && transform_version != 3) || (!is_loca_or_glyf && transform_version != 0)
        }
      end

      struct :collection_directory, onlyif: :has_collection? do
        uint32 :version
        uint16 :num_fonts # 255UInt16

        array :collection_font_entries, initial_length: :num_fonts do
          uint16 :num_collection_tables # 255UInt16
        end
      end

      string :compressed_data, read_length: :total_compressed_size

      string :metadata, read_length: :meta_length

      rest :private_data

      def has_collection?
        flavor == 0x74746366
      end
    end
  end
end
