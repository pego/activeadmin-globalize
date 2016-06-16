require 'active_admin/views/components/status_tag'

module ActiveAdmin
  module Globalize
    module IndexTableFor
      def translated_column attr
        column attr do |record|
          unless record.translated_attribute_names.include?(attr.to_sym)
            raise "#{attr} is not translated attribute"
          end

          all_translations = (I18n.available_locales + record.translation_codes).uniq

          translations = {}

          div do
            all_translations.map do |locale|
              translations[locale] = record.translated_attribute_by_locale(attr)[locale.to_s]

              attrs = {class: "status_tag #{translations[locale].present? ? "green" : "red"}"}
              if translations[locale]
                attrs[:class] = "#{attrs[:class]} hint--bottom"
                attrs["aria-label"] = translations[locale]
              end

              span(locale, attrs)
            end
          end
        end
      end

      def translation_status
        column I18n.t("active_admin.globalize.translations") do |record|
          record.translation_names.map do |t|
            '<span class="status_tag">%s</span>' % t
          end.join(" ").html_safe
        end
      end
    end
  end
end
