# frozen_string_literal: true

module Spree
  StoreController.class_eval do
    before_action :set_locale

# START set_locale
def set_locale

      #ToDo Set order currency to match current currency check.
      #if current_order
        #if current_order.currency != current_currency
          #params[:currency] = current_currency
        #end
      #end


      # IF the visitor has previously set a prefered currency, then set the store to use the visitors preffered currency.
      if (!cookies[:customer_preffered_currency].blank?) && (cookies[:customer_preffered_currency_returing_set].blank?) && (cookies[:customer_preffered_currency]) != current_currency

          params[:currency] = (cookies[:customer_preffered_currency]).to_s
          (cookies[:customer_preffered_currency_returing_set] = 'true')
      end

      # Only run the code below once, or no at all if the visitor has already set a prefered currency.
      if (cookies[:geo_currency].blank?) && (cookies[:customer_preffered_currency].blank?)

          # Define a list of countires that use Euros.
          euro_zone_countries = [ 'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'EL',
                                        'HU', 'IE', 'IT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SV' ]

          # IF the store is loaded with I18n.default_locale, and the visitor is not a bot.
          if locale == I18n.default_locale && !browser.bot?

              # IF the visitor is located in a Euro Zone country (EZ)
              if euro_zone_countries.include? request.headers["CF-IPCountry"].to_s
                visitor_location = "EZ"
                else
                visitor_location = request.headers["CF-IPCountry"].to_s
              end

              case visitor_location
                when 'EZ'
                  params[:currency] = "EUR"
                when 'GB'
                  params[:currency] = "GBP"
                when 'AU'
                  params[:currency] = "AUD"
                when 'CA'
                  params[:currency] = "CAD"
                else
                  params[:currency] = "USD"
              end

          # ELSE check for language locale in the URL and set currency appropriately
          else
              case locale
                when :'de', :'fr', :'it', :'es', :'sv'
                  params[:currency] = "EUR"
                when :'en-GB'
                  params[:currency] = "GBP"
                when :'en-AU'
                  params[:currency] = "AUD"
                when :'en-CA'
                  params[:currency] = "CAD"
                when :'en-US'
                  params[:currency] = "USD"
                else
                  params[:currency] = "USD"
              end
          end
          (cookies[:geo_currency] = params[:currency])
      end

  # Switches the currency based on the paremeters given.
  if params[:currency].present?
    @currency = supported_currencies.find { |currency| currency.iso_code == params[:currency] }
    current_order.update_attributes!(currency: @currency.iso_code) if @currency && current_order
    session[:currency] = params[:currency] if Spree::Config[:allow_currency_change]
  end

end
# END set_locale

  end
end
