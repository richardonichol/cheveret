#--
# Copyright (c) 2010 RateCity Pty. Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Cheveret
  module Table
    module Rendering

      def self.included(base)
        base.module_eval do
          extend ClassMethods
        end
      end

      attr_accessor :template

      module ClassMethods
      end # ClassMethods

      ##
      #
      #
      def render_table(options={})
        table_tag(options) do
          render_thead << render_tbody
        end
      end

      ##
      #
      #
      def render_thead(options={})
        thead_tag(options) do
          tr_tag do
            columns.values.map do |column|
              render_th(column) { table_header(column) }
            end
          end
        end
      end

      ##
      #
      #
      def render_tbody(options={})
        tbody_tag(options) { render_rows }
      end

      ##
      #
      #
      def render_rows(options={})
        template.reset_cycle('cheveret')

        collection.map do |item|
          cycle = template.cycle('', 'alt', :name => 'cheveret')

          tr_tag(:class => cycle) do
            columns.values.map do |column|
              render_td(column) { table_data(column, item) }
            end
          end
        end.join("\n")
      end

      ##
      # generates a <th> tag for the specified column using the configured builder
      #
      def render_th(column, options={})
        options.reverse_merge!(column.th_html) if column.th_html

        # phwarrrgg!
        options[:class] = ([ column.name, options[:class],
          column.th_html ? column.th_html[:class] : nil
        ]).flatten.join(' ').strip

        th_tag(options) { yield }
      end

      ##
      #
      #
      def render_td(column, options={})
        options.reverse_merge!(column.td_html) if column.td_html
        options[:class] = [ column.name, *options[:class] ].flatten.join(' ').strip

        td_tag(options) { yield }
      end

      ##
      #
      #
      def render(*args, &block)
        if args.empty? && block_given?
          template.instance_eval(&block)
        else
          template.render(*args, &block)
        end
      end

    end # Rendering
  end # Table
end # Cheveret
