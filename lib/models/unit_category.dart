import 'package:fati_project_ios/services/currency_service.dart';
import 'package:flutter/material.dart';

class UnitCategory {
  final String name;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> units;
  final Color color;

  UnitCategory({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.units,
    required this.color,
  });

  static List<UnitCategory> getAllCategories() {
    return [
      UnitCategory(
        name: 'Currency',
        title: 'Currency',
        subtitle: 'Exchange rates & monetary units',
        icon: Icons.payments_outlined,
        color: const Color(0xFF34C759),
        units: [], // Will be populated dynamically from API
      ),
      UnitCategory(
        name: 'Length',
        title: 'Length',
        subtitle: 'Distance & dimension units',
        icon: Icons.straighten,
        color: const Color(0xFF007AFF),
        units: ['Meter', 'Kilometer', 'Centimeter', 'Millimeter', 'Mile', 'Foot', 'Inch', 'Yard'],
      ),
      UnitCategory(
        name: 'Weight',
        title: 'Weight',
        subtitle: 'Mass & weight measurements',
        icon: Icons.fitness_center,
        color: const Color(0xFFFF9500),
        units: ['Gram', 'Kilogram', 'Pound', 'Ounce', 'Ton', 'Stone'],
      ),
      UnitCategory(
        name: 'Temperature',
        title: 'Temperature',
        subtitle: 'Heat & cold measurements',
        icon: Icons.thermostat_outlined,
        color: const Color(0xFFFF3B30),
        units: ['Celsius', 'Fahrenheit', 'Kelvin'],
      ),
      UnitCategory(
        name: 'Area',
        title: 'Area',
        subtitle: 'Surface area calculations',
        icon: Icons.crop_square,
        color: const Color(0xFF5856D6),
        units: ['Square Meter', 'Square Kilometer', 'Square Mile', 'Acre', 'Hectare', 'Square Foot'],
      ),
      UnitCategory(
        name: 'Volume',
        title: 'Volume',
        subtitle: 'Capacity & liquid measurements',
        icon: Icons.local_drink_outlined,
        color: const Color(0xFF32D74B),
        units: ['Liter', 'Milliliter', 'Gallon', 'Cup', 'Pint', 'Quart', 'Fluid Ounce'],
      ),
      UnitCategory(
        name: 'Speed',
        title: 'Speed',
        subtitle: 'Velocity & pace measurements',
        icon: Icons.speed,
        color: const Color(0xFFAF52DE),
        units: ['Meter/Second', 'Kilometer/Hour', 'Mile/Hour', 'Knot', 'Foot/Second'],
      ),
      UnitCategory(
        name: 'Time',
        title: 'Time',
        subtitle: 'Duration & time intervals',
        icon: Icons.access_time,
        color: const Color(0xFF00C7BE),
        units: ['Second', 'Minute', 'Hour', 'Day', 'Week', 'Month', 'Year'],
      ),
    ];
  }

  // Method to get available currencies from the currency service
  static Future<List<String>> getAvailableCurrencies() async {
    try {
      final rates = await CurrencyService.getExchangeRates();
      final currencies = rates.keys.toList();
      currencies.sort(); // Sort alphabetically
      return currencies;
    } catch (e) {
      // Return fallback currencies if API fails
      return [
        'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 
        'INR', 'BRL', 'KRW', 'SGD', 'MXN', 'RUB', 'ZAR', 'NOK',
        'SEK', 'DKK', 'PLN', 'CZK', 'HUF', 'TRY', 'ILS', 'AED',
        'SAR', 'THB', 'MYR', 'PHP', 'IDR', 'VND', 'HKD', 'TWD', 'NZD'
      ];
    }
  }
}
