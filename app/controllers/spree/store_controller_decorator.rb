# frozen_string_literal: true

module Spree
  StoreController.class_eval do
    before_action :set_locale

      # START set_locale
      def set_locale

          # IF a preferred currency is set, then use the preferred currency.
          if (cookies[:preferred_currency].present?) && (cookies[:preferred_currency]) != current_currency
              params[:currency] = (cookies[:preferred_currency])
          end

          # Only run the code below once, and only IF the visitor has NOT already set a preferred currency.
          if session[:currency].blank? && (cookies[:preferred_currency].blank?)
              # Define a list of countires that use Euros.
              euro_zone_countries = [ 'AT', 'BE', 'BG', 'HR', 'CY',
                                      'CZ', 'DK', 'EE', 'FI', 'FR',
                                      'DE', 'EL', 'HU', 'IE', 'IT',
                                      'LU', 'MT', 'NL', 'PL', 'PT',
                                      'RO', 'SK', 'SI', 'ES', 'SV' ]

              # IF the store is loaded with I18n.default_locale, and the visitor is not a bot.
              if locale == I18n.default_locale && !browser.bot?

                  # IF the visitor is located in a Euro Zone country (EZ)
                  if euro_zone_countries.include? request.headers['CF-IPCountry'].to_s
                    visitor_location = 'EZ'
                    else
                    visitor_location = request.headers['CF-IPCountry'].to_s
                  end

                  case visitor_location
                    when 'EZ'
                      params[:currency] = 'EUR'
                    when 'GB'
                      params[:currency] = 'GBP'
                    when 'AU'
                      params[:currency] = 'AUD'
                    when 'CA'
                      params[:currency] = 'CAD'
                    else
                      params[:currency] = 'USD'
                  end

              # ELSE check for language locale in the URL and set currency appropriately
              else
                  case locale
                    when :'de', :'fr', :'it', :'es', :'sv'
                      params[:currency] = 'EUR'
                    when :'en-GB'
                      params[:currency] = 'GBP'
                    when :'en-AU'
                      params[:currency] = 'AUD'
                    when :'en-CA'
                      params[:currency] = 'CAD'
                    when :'en-US'
                      params[:currency] = 'USD'
                    else
                      params[:currency] = 'USD'
                  end
              end
              session[:currency] = params[:currency]
          end

          # Keep the store currency and order currency in sync
          if current_order
            if current_order.currency != current_currency
              params[:currency] = current_order.currency
              (cookies[:preferred_currency] = { value: current_order.currency, expires: 1.year.from_now })
            end
          end

          # Switch the currency based on the params given.
          if params[:currency].present?
            @currency = supported_currencies.find { |currency| currency.iso_code == params[:currency] }
            current_order.update_attributes!(currency: @currency.iso_code) if @currency && current_order
            session[:currency] = params[:currency] if Spree::Config[:allow_currency_change]
          end

      end
      # END set_locale

  end
end
