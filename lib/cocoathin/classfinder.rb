require 'singleton'
require 'pathname'
require 'rainbow'

module Cocoathin
  class Classfinder

    include Singleton

    def find_class(path, prefix)
      # check_file_type(path)
      allList,reflist = split_segment_and_find(path, prefix)
      return allList,reflist
    end

    def split_segment_and_find(path, prefix)

      arch_command = "lipo -info #{path}"
      arch_output = `#{arch_command}`

      arch = 'arm64'
      if arch_output.include? 'arm64'
        arch = 'arm64'
      elsif arch_output.include? 'x86_64'
        arch = 'x86_64'
      elsif arch_output.include? 'armv7'
        arch = 'armv7'
      end

      command = "/usr/bin/otool -arch #{arch}  -V -o #{path}"
      output = `#{command}`

      class_list_identifier = 'Contents of (__DATA,__objc_classlist) section'
      class_refs_identifier = 'Contents of (__DATA,__objc_classrefs) section'

      unless output.include? class_list_identifier
        Rainbow("only support iphone target, please use iphone build... \n path:#{path}").red
        return [],[]
      end

      patten = /Contents of \(.*\) section/

      name_patten_string = '.*'
      unless prefix.empty?
        name_patten_string = "#{prefix}.*"
      end

      vmaddress_to_class_name_patten = /^(\d*\w*)\s(0x\d*\w*)\s_OBJC_CLASS_\$_(#{name_patten_string})/

      class_list = []
      used_vmaddress_to_class_name_hash = {}

      can_add_to_list = false
      can_add_to_refs = false

      output.each_line do |line|
        if patten.match?(line)
          if line.include? class_list_identifier
            can_add_to_list = true
            next
          elsif line.include? class_refs_identifier
            can_add_to_list = false
            can_add_to_refs = true
          else
            break
          end
        end

        if can_add_to_list
          class_list << line
        end

        if can_add_to_refs && line
          vmaddress_to_class_name_patten.match(line) do |m|
            unless used_vmaddress_to_class_name_hash[m[2]]
              used_vmaddress_to_class_name_hash[m[2]] = m[3]
            end
          end
        end
      end

      # remove cocoapods class
      podsd_dummy = 'PodsDummy'

      vmaddress_to_class_name_hash = {}
      class_list.each do |line|
        next if line.include? podsd_dummy
        vmaddress_to_class_name_patten.match(line) do |m|
          vmaddress_to_class_name_hash[m[2]] = m[3]
        end
      end

      return vmaddress_to_class_name_hash.values, used_vmaddress_to_class_name_hash.values

      # result = vmaddress_to_class_name_hash
      # vmaddress_to_class_name_hash.each do |key, value|
      #   if used_vmaddress_to_class_name_hash.keys.include?(key)
      #     result.delete(key)
      #   end
      # end
      #
      # result
    end

    def check_file_type(path)
      pathname = Pathname.new(path)
      # unless pathname.exist?
      #   raise "#{path} not exit!"
      # end

      cmd = "/usr/bin/file -b #{path}"
      output = `#{cmd}`

      unless output.include?('Mach-O')
        raise 'input file not mach-o file type'
      end
      pathname
    end

  end
end