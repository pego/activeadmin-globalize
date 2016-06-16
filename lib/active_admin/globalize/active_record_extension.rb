module ActiveAdmin::Globalize
  module ActiveRecordExtension

    module Methods
      def translation_codes
        self.translations.map(&:locale).map(&:to_sym).uniq
      end

      def translation_names
        self.translations.map(&:locale).map do |locale|
          I18n.t("active_admin.globalize.language.#{locale}")
        end.uniq.sort
      end
    end

    def active_admin_translates(*args, &block)
      # Remove options
      args.extract_options!
      translates(*args.dup)

      if block
        translation_class.instance_eval(&block)
        # translation_class.instance_eval do
        #   with_options(on: :active_admin) do |active_admin|
        #     active_admin.instance_eval(&block)
        #   end
        # end
      end

      accepts_nested_attributes_for :translations, allow_destroy: true

      include Methods
    end
  end
end
