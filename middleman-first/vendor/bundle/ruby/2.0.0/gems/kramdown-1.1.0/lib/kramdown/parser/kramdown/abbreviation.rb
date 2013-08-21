# -*- coding: utf-8 -*-
#
#--
# Copyright (C) 2009-2013 Thomas Leitner <t_leitner@gmx.at>
#
# This file is part of kramdown which is licensed under the MIT.
#++
#

module Kramdown
  module Parser
    class Kramdown

      ABBREV_DEFINITION_START = /^#{OPT_SPACE}\*\[(.+?)\]:(.*?)\n/

      # Parse the link definition at the current location.
      def parse_abbrev_definition
        @src.pos += @src.matched_size
        abbrev_id, abbrev_text = @src[1], @src[2]
        abbrev_text.strip!
        warning("Duplicate abbreviation ID '#{abbrev_id}' - overwriting") if @root.options[:abbrev_defs][abbrev_id]
        @root.options[:abbrev_defs][abbrev_id] = abbrev_text
        @tree.children << Element.new(:eob, :abbrev_def)
        true
      end
      define_parser(:abbrev_definition, ABBREV_DEFINITION_START)

      # Replace the abbreviation text with elements.
      def replace_abbreviations(el, regexps = nil)
        return if @root.options[:abbrev_defs].empty?
        if !regexps
          sorted_abbrevs = @root.options[:abbrev_defs].keys.sort {|a,b| b.length <=> a.length}
          regexps = [Regexp.union(*sorted_abbrevs.map {|k| /#{Regexp.escape(k)}/})]
          regexps << /(?=(?:\W|^)#{regexps.first}(?!\w))/ # regexp should only match on word boundaries
        end
        el.children.map! do |child|
          if child.type == :text
            if child.value =~ regexps.first
              result = []
              strscan = StringScanner.new(child.value)
              while temp = strscan.scan_until(regexps.last)
                abbr = strscan.scan(regexps.first) # begin of line case of abbr with \W char as first one
                if abbr.nil?
                  temp << strscan.scan(/\W|^/)
                  abbr = strscan.scan(regexps.first)
                end
                result << Element.new(:text, temp) << Element.new(:abbreviation, abbr)
              end
              result << Element.new(:text, strscan.rest)
            else
              child
            end
          else
            replace_abbreviations(child, regexps)
            child
          end
        end.flatten!
      end

    end
  end
end