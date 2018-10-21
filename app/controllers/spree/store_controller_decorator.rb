module Spree
  StoreController.class_eval do
    before_action :set_locale

    def set_locale

      # List the countires that you want to default to the Euro € on first pageload.
      euro_zone_countries = [ 'AT', 'BE', 'BG', 'HR', 'CY',
                         'CZ', 'DK', 'EE', 'FI', 'FR',
                         'DE', 'EL', 'HU', 'IE', 'IT',
                         'LU', 'MT', 'NL', 'PL', 'PT',
                         'RO', 'SK', 'SI', 'ES', 'SV' ]

      # Only run the code once on first pageload, allowing the user to change the store currency if they wish.
      if (cookies[:geo_currency].blank?)


          if locale == I18n.default_locale && !request.location.country_code.nil? && !browser.bot?
          # If the website is loaded with the default language loacls, and the visitor has a country code, and the visitor is not a bot.

                  # Test if the visitor is located in a Euro Zone country (EZ)
                  if euro_zone_countries.include? request.location.country_code.to_s
                    visitor_location = "EZ"
                    else
                    visitor_location = request.location.country_code
                  end

                  if      visitor_location == "EZ"
                                params[:currency] = "EUR"
                    elsif visitor_location == "GB"
                                params[:currency] = "GBP"
                    elsif visitor_location == "AU"
                                params[:currency] = "AUD"
                    elsif visitor_location == "CA"
                                params[:currency] = "CAD"
                    else
                                params[:currency] = "USD"
                  end

            # Else check for language locals and set currency appropriatly
            elsif locale == :'de'
              params[:currency] = "EUR"
            elsif locale == :'fr'
              params[:currency] = "EUR"
            elsif locale == :'it'
              params[:currency] = "EUR"
            elsif locale == :'es'
              params[:currency] = "EUR"
            elsif locale == :'sv'
              params[:currency] = "EUR"
            elsif locale == :'en-GB'
              params[:currency] = "GBP"
            elsif locale == :'en-AU'
              params[:currency] = "AUD"
            elsif locale == :'en-CA'
              params[:currency] = "CAD"
            elsif locale == :'en-US'
              params[:currency] = "USD"
          end
          
          (cookies[:geo_currency] = params[:currency])
      end

      if params[:currency].present?
        @currency = supported_currencies.find { |currency| currency.iso_code == params[:currency] }
        current_order.update_attributes!(currency: @currency.iso_code) if @currency && current_order
        session[:currency] = params[:currency] if Spree::Config[:allow_currency_change]
      end
    end

  end
end
