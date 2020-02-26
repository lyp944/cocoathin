require 'pathname'

module Cocoathin

  class Clsmodel
    attr_accessor :path
    attr_accessor :name
    attr_accessor :method_list

    def initialize(path, name)
      @path = path
      @name = name
      @method_list = []
    end

    def add_method(method)
      @method_list << method
    end

    def to_s
      %Q(
      #{@name}\n
      #{@path}\n
      #{@method_list}
      )
    end

  end

  class Dwarfparser
    def self.find_class(path)
      class_name_list = []
      list = self.find_class_model(path)
      list.each do |item|
        class_name_list << item.name
      end
      class_name_list
    end

    def self.find_selector(path)
      selector_list = []
      list = self.find_class_model(path)
      list.each do |item|
        selector_list += item.method_list
      end
      selector_list
    end

    def self.find_class_model(path)
      command = "/usr/bin/dwarfdump -debug-info #{path}"
      output = `#{command}`

      debug_info_patten = /^.debug_info contents:\s*/
      class_desc_patten = /0x\w*:\s*DW_TAG_compile_unit\s*/
      class_name_patten = /\s*DW_AT_name\s*\("(.+)"\)/

      method_begin_patten = /0x\w*:\s*DW_TAG_subprogram\s*/
      method_name_patten = /\s*DW_AT_name\s*\("(.+)"\)\s*/

      new_line_patten = /^\n$/

      in_debug_info = false
      in_class_desc = false
      in_method_desc = false

      class_list = []
      last_instance = nil

      output.each_line do |line|
        # new debug-info area
        #

        if debug_info_patten.match?(line)
          in_debug_info = true
          in_class_desc = false
          in_method_desc = false
        elsif class_desc_patten.match?(line)
          in_debug_info = false
          in_class_desc = true
          in_method_desc = false
        elsif method_begin_patten.match?(line)
          in_debug_info = false
          in_class_desc = false
          in_method_desc = true
        end

        # end one method
        if in_class_desc && new_line_patten.match?(line)
          in_class_desc = false
        end

        # end one method
        if in_method_desc && new_line_patten.match?(line)
          in_method_desc = false
        end

        if in_debug_info
          last_instance = nil
        elsif in_class_desc
          class_name_patten.match(line) do |m|
            class_name = Pathname.new(m[1]).basename('.*').to_s
            class_name = class_name.sub(/\+/, '_')
            last_instance = Clsmodel.new(m[1].to_s, class_name)
            class_list << last_instance
          end
        elsif in_method_desc

          method_name_patten.match(line) do |m|
            last_instance.add_method(m[1].to_s)
          end
        end
      end
      class_list
    end


  end
end
