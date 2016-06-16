class ActiveAdmin::Views::AttributesTable
  include ActiveAdmin::ViewHelpers::DisplayHelper
end

class TranslationAttributes
  def initialize translation, *attrs, &block

    @html = Arbre::Context.new do
      div class: "translated_attributes locale locale-#{translation.locale}" do
        table = attributes_table_for(translation, *attrs)
        table.instance_eval(&block)
      end
    end
  end

  def to_s
    @html.to_s
  end
end

module ActiveAdmin
  module Globalize

    module RowFor

      def make_buffer
        "".html_safe
      end

      def translated_rows *attributes, &block
        options = attributes.extract_options!
        options.symbolize_keys!
        switch_locale = options.fetch(:switch_locale, false)
        auto_sort = options.fetch(:auto_sort, true)

        object = @collection.first

        html = make_buffer

        # Create header with tabs
        html << content_tag(:div, class: "activeadmin-translations") do
          inner_html = make_buffer

          # Header with language switchers
          inner_html << content_tag(:ul, class: "available-locales") do
            (auto_sort ? I18n.available_locales.sort : I18n.available_locales).map do |locale|
              content_tag(:li) do
                I18n.with_locale(switch_locale ? locale : I18n.locale) do
                  content_tag(:a, I18n.t(:"active_admin.globalize.language.#{locale}"), href:".locale-#{locale}")
                end
              end
            end.join.html_safe
          end

          # Get available locales (and sort them if auto_sort)
          locales = (auto_sort ? I18n.available_locales.sort : I18n.available_locales)

          inner_html << locales.map do |locale|
            # Get translations for locale
            translation = object.translations.find { |t| t.locale.to_s == locale.to_s }
            # Or build new when not presented
            translation ||= object.translations.build(locale: locale)

            # Switch locale if switch_locale
            I18n.with_locale(switch_locale ? locale : I18n.locale) do
              # Create attribute table

              # attributes_component = ActiveAdmin::Views::AttributesTable.new()
              # attributes_component.build(translation, *attributes)
              # attributes_component.instance_eval(&block) if block_given?

              # html = Arbre::Context.new do
              #   attributes_table_for(translation)
              # end

              # p html
              #  do |localized_table|
              #   localized_table.instance_eval(&block)
              # end

              translated_table = TranslationAttributes.new(translation, *attributes, &block)

              content_tag(
                :div,
                translated_table.to_s,
                class: "translated_attributes locale locale-#{translation.locale}"
              )
            end
          end.join.html_safe
        end

        @table << tr do
          td(html, colspan: 2)
        end
      end
    end
  end
end
