# frozen_string_literal: true
require 'cocoathin/version'
require 'cocoathin/classfinder'
require 'cocoathin/selectorfinder'
require 'cocoathin/filefinder'
require 'cocoathin/dwarfparser'
require 'thor'

module Cocoathin
  class Error < StandardError; end
  # Your code goes here...

  class Commander < Thor
    desc 'findsel','find unused method sel'
    method_option :prefix, default: '', type: :string, desc: 'the class prefix you want find'
    method_option :ignore, default: true, type: :boolean, desc: 'ignore the .framework and .a'
    def findsel(rootpath)
      prefix = options[:prefix]
      ignore = options[:ignore]
      find_sel_imp(rootpath, prefix, ignore)
    end

    desc 'findclass', 'find unused class list'
    method_option :prefix, default: '', type: :string, desc: 'the class prefix you want find'
    method_option :ignore, default: true, type: :boolean, desc: 'ignore the .framework and .a'
    def findclass(rootpath)

      prefix = options[:prefix]
      ignore = options[:ignore]
      find_class_imp(rootpath, prefix, ignore)
    end

    desc'version','print version'
    def version
      puts Rainbow(Cocoathin::VERSION).green
    end

  end

  class GemImp
    # imp
    def self.find_class_imp(rootpath, prefix: '', ignore: true)

      fileFinder = Filefinder.new(rootpath)
      puts Rainbow('Find unused class list process...').green
      ignore_classname_list = []
      if ignore

        a_path_list = fileFinder.find_a()
        a_path_list.each do |path|

          list = Dwarfparser.find_class(path)
          ignore_classname_list += list
        end

        framework_path_list = fileFinder.find_framework()

        framework_path_list.each do |path|
          pn = Pathname.new(path)
          machpath = path + pn.basename('.*').to_s
          alllist, reflist = Classfinder.instance.find_class(machpath, prefix)
          ignore_classname_list += alllist
        end

      end

      app_mach_path = fileFinder.find_app_mach()

      all_classname_list, ref_classname_list = Classfinder.instance.find_class(app_mach_path,prefix)
      unused = all_classname_list - ref_classname_list - ignore_classname_list

      puts Rainbow('Unused class list bellow:').green
      unused
    end

    def self.find_sel_imp(rootpath, prefix: '', ignore: true)
      fileFinder = Filefinder.new(rootpath)
      puts Rainbow('Find unused selector list process...').green
      ignore_sel_list = []
      if ignore

        a_path_list = fileFinder.find_a()
        a_path_list.each do |path|

          list = Dwarfparser.find_selector(path)
          ignore_sel_list += list
        end

        framework_path_list = fileFinder.find_framework()

        framework_path_list.each do |path|
          pn = Pathname.new(path)
          machpath = path + pn.basename('.*').to_s
          sel_list = Selectorfinder.instance.find_unused_sel(machpath, prefix)
          ignore_sel_list += sel_list
        end

      end

      app_mach_path = fileFinder.find_app_mach()

      unused_sel_list = Selectorfinder.instance.find_unused_sel(app_mach_path,prefix)
      unused = unused_sel_list - ignore_sel_list
      puts Rainbow('Unused selector list bellow:').green
      unused
    end

  end

end
