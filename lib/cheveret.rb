#--
# Copyright (c) 2010 RateCity
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

require 'forwardable'

module Cheveret
  class Table
    attr_accessor :columns

    def initialize()
      @columns = ::ActiveSupport::OrderedHash.new
    end

    def columns(*args, &block)
      return @columns.values unless block_given?
      instance_eval(&block)
      # todo: support populating columns from an array
      # todo: attempt to automatically resolve columns from activerecord etc.
    end

    def add_column(column_name, config={})
      @columns[column_name] = Column.new(column_name, config)
    end

    alias_method :column, :add_column

    def fixed(column_name, config={})
      add_column(column_name, config.merge({ :flexible => false }))
    end

    def flexible(column_name, config={})
      add_column(column_name, config.merge({ :flexible => true }))
    end

    def hidden(column_name, config={})
      add_column(column_name, config.merge({ :visible => false }))
    end

    def remove_column(column_name)
      # todo: allow columns to be removed, not sure why you'd want to do this. maybe
      # just set :visible => false instead?
      raise NotImplementedError
    end

    def resize!(new_width)
      return true if new_width == @width
      @width = new_width

      columns_width = 0
      flexibles     = []

      self.columns.each do |column|
        if column.visible?
          columns_width += column.width
          flexibles << column.name if column.flexible?
        end
      end

      # todo: handle too-many/too-wide columns
      raise "uh-oh spaghettio-s" if columns_width > new_width

      # todo: fix rounding in with calculation
      # todo: trim last column that fits into table width if necessary
      if columns_width < new_width && !flexibles.empty?
        padding = (new_width - columns_width) / flexibles.length
        flexibles.each { |name| @columns[name].width += padding }
      end
    end
  end

  class Column
    extend ::Forwardable

    [ :width, :visible, :flexible, :label, :sortable ].each do |attr|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def_delegator :@config, :#{attr}, :#{attr}
        def_delegator :@config, :#{attr}=, :#{attr}=
      RUBY_EVAL
    end

    attr_accessor :name

    def initialize(column_name, config={})
      @name = column_name

      @config = ::ActiveSupport::OrderedOptions.new
      config.each { |k, v| send("#{k}=", v) if respond_to?(k) }
    end

    # sets the column to be visible. columns are visible by default. use this when
    # you've defined hidden columns that should only be displayed on some condition
    def show
      self.visible = true
    end

    # hides the column, prevents it from being rendered in the table
    # helper for setting :visible => false
    def hide
      self.visible = false
    end

    # returns true for columns that have :visible => true or #show called on them
    # columns are visible by default
    def visible?
      self.visible != false
    end

    def flexible?
      self.flexible != false
    end

    def label
      case @config.label
      when nil then @name.to_s.humanize # todo: support i18n for column labels
      when false then nil
      else @config.label
      end
    end

    def data(object)
      object.send(self.name) if object.respond_to?(self.name)
    end

    def width
      @config.width || 0
    end
  end

  module Helpers
    # renders a table for a collection of objects
    def table_for(collection, options={}, &block)
      builder = options.delete(:builder) || ActionView::Base.default_table_builder

      options.merge!({ :collection => collection })
      builder.render(Table.new, self, options, &block)
    end

    class TableBuilder
      extend ::Forwardable
      def_delegators :@table, :columns

      def self.render(table, template, options={}, &block)
        html_attrs = options.delete(:html) || {}
        html_attrs.merge!({ :class => "table",
                            :style => "width: #{options[:width]}px;" })

        template.content_tag(:div, html_attrs) do
          template.capture(self.new(table, template, options), &block)
        end
      end

      def initialize(table, template, options={})
        @table, @template, = table, template

        @width = options.delete(:width)
        @collection = options.delete(:collection)
      end

      def header(*args, &block)
        @table.resize!(@width)

        row = @template.content_tag(:div, :class => "tr") do
          map_columns(:th) do |column|
            # todo: prevent output of empty <a> tag for header label
            output   = nil_capture(column, &block) if block_given?
            output ||= @template.content_tag(:a, column.label)
          end
        end

        @template.content_tag(:div, row, :class => "thead")
      end

      def body(&block)
        @table.resize!(@width)
        alt = false

        rows = @collection.map do |object|
          object_name = object.class.to_s.split('::').last.underscore || ''
          klass = [ 'tr', object_name, (alt = !alt) ? nil : 'alt' ].compact
          @template.content_tag(:div, :class => klass.join(' ')) do
            map_columns(:td) do |column|
              output   = nil_capture(column, object, &block) if block_given?
              output ||= @template.content_tag(:span, column.data(object))
            end
          end
        end

        @template.content_tag(:div, rows.join, :class => "tbody")
      end

    private

      def map_columns(type, &block) #:nodoc:
        @table.columns.map do |column|
          attrs = { :class => [type, column.name].join(' '),
                    :style => "width: #{column.width}px;" }

          @template.content_tag(:div, attrs) do
            yield(column)
          end if column.visible?
        end
      end

      def nil_capture(*args, &block) #:nodoc:
        custom = @template.capture(*args, &block).strip
        output = custom.empty? ? nil : custom
      end
    end
  end

  ActionView::Base.class_eval do
    cattr_accessor :default_table_builder
    self.default_table_builder = ::Cheveret::Helpers::TableBuilder
  end
end