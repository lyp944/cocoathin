require 'pathname'
require 'find'

module Cocoathin
  class Filefinder

    @rootpath

    def initialize(rootpath)
      @rootpath = rootpath
    end

    # find xx.framework
    def find_framework()
      framework_list = []

      Find.find(@rootpath) do |path|
        pn = Pathname.new(path)
        ext = pn.extname
        if ext == '.framework'
          framework_list << path
          Find.prune
        elsif ext == '.app'
          Find.prune
        end
      end

      framework_list
    end

    # find xx.a
    def find_a()
      a_list = []
      Find.find(@rootpath) do |path|
        pn = Pathname.new(path)
        ext = pn.extname
        if ext == '.a'
          a_list << path
          Find.prune
        elsif ext == '.app'
          Find.prune
        end
      end
      a_list
    end

    def find_app_machs()
      list = []
      Pathname.new(@rootpath).children.each do |pn|
        ext = pn.extname
        if ext == '.app'
          path = pn.to_s + '/' + pn.basename('.app').to_s
          list << path
        end
      end
      list
    end

    def find_app_mach()
      Find.find(@rootpath) do |path|
        pn = Pathname.new(path)
        ext = pn.extname
        return path + '/' + pn.basename('.app').to_s if ext == '.app'
      end
    end

  end
end
