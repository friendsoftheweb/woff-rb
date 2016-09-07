module WOFF
  class Data < ::BinData::Record
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

    array :table_directory, :initial_length => :num_tables do
      uint32 :tag
      uint32 :table_offset
      uint32 :comp_length
      uint32 :orig_length
      uint32 :orig_checksum
    end

    string :fonts, :read_length => lambda {
      dir = table_directory.sort_by { |entry| entry["table_offset"] }

      first_table_start = dir.first["table_offset"]
      last_table_end = dir.last["table_offset"] + dir.last["comp_length"]

      table_length = last_table_end - first_table_start

      # Next largest number divisible by 4
      (table_length / 4.0).ceil * 4
    }

    string :metadata, :read_length => :meta_length

    rest :private_data
  end
end
