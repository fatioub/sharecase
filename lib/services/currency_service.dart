import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CurrencyService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  static Map<String, double>? _cachedRates;
  static DateTime? _lastUpdate;
  static const Duration _cacheValidDuration = Duration(hours: 1);
  static bool _debugMode = kDebugMode;
  static String? _lastError;
  static int _availableRatesCount = 0;
  static bool _isLiveData = false;

  static Future<Map<String, double>> getExchangeRates({String baseCurrency = 'USD'}) async {
    if (_debugMode) {
      debugPrint('[CurrencyService] Starting API request for $baseCurrency');
    }

    // Check if we have valid cached data
    if (_cachedRates != null && 
        _lastUpdate != null && 
        DateTime.now().difference(_lastUpdate!) < _cacheValidDuration) {
      if (_debugMode) {
        debugPrint('[CurrencyService] Using cached data from ${_lastUpdate!}');
        debugPrint('[CurrencyService] Cached rates count: $_availableRatesCount');
      }
      return _cachedRates!;
    }

    try {
      if (_debugMode) {
        debugPrint('[CurrencyService] Making HTTP request to: $_baseUrl/$baseCurrency');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$baseCurrency'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (_debugMode) {
        debugPrint('[CurrencyService] HTTP response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (_debugMode) {
          debugPrint('[CurrencyService] API response data keys: ${data.keys}');
          debugPrint('[CurrencyService] Base currency: ${data['base']}');
          debugPrint('[CurrencyService] Date: ${data['date']}');
          debugPrint('[CurrencyService] Number of rates: ${data['rates']?.length ?? 0}');
        }

        // Fix type casting issue - some values might be int instead of double
        final rawRates = data['rates'] as Map<String, dynamic>;
        final rates = <String, double>{};
        
        for (final entry in rawRates.entries) {
          final value = entry.value;
          if (value is num) {
            rates[entry.key] = value.toDouble();
          } else {
            if (_debugMode) {
              debugPrint('[CurrencyService] Skipping invalid rate for ${entry.key}: $value');
            }
          }
        }
        
        // Cache the rates
        _cachedRates = rates;
        _lastUpdate = DateTime.now();
        _lastError = null;
        _availableRatesCount = rates.length;
        _isLiveData = true;
        
        if (_debugMode) {
          debugPrint('[CurrencyService] Successfully cached $_availableRatesCount exchange rates (LIVE DATA)');
          debugPrint('[CurrencyService] Sample rates: USD: ${rates['USD']}, EUR: ${rates['EUR']}, GBP: ${rates['GBP']}');
        }
        
        return rates;
      } else {
        final errorMsg = 'Failed to fetch exchange rates: ${response.statusCode}';
        _lastError = errorMsg;
        if (_debugMode) {
          debugPrint('[CurrencyService] API Error: $errorMsg');
          debugPrint('[CurrencyService] Response body: ${response.body}');
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      _lastError = e.toString();
      if (_debugMode) {
        debugPrint('[CurrencyService] Exception occurred: $e');
        debugPrint('[CurrencyService] Falling back to hardcoded rates');
      }
      // If network fails, return fallback rates
      return getFallbackRates();
    }
  }

  static Map<String, double> getFallbackRates() {
    if (_debugMode) {
      debugPrint('[CurrencyService] Using fallback rates');
    }
    
    final fallbackRates = {
      'USD': 1.0,
      'EUR': 0.92,
      'GBP': 0.78,
      'JPY': 155.0,
      'CAD': 1.36,
      'AUD': 1.52,
      'CHF': 0.91,
      'CNY': 7.24,
      'INR': 83.12,
      'BRL': 4.95,
      'KRW': 1320.0,
      'SGD': 1.35,
      'MXN': 17.25,
      'RUB': 92.5,
      'ZAR': 18.75,
      'NOK': 10.85,
      'SEK': 11.25,
      'DKK': 6.85,
      'PLN': 4.25,
      'CZK': 23.15,
      'HUF': 365.0,
      'TRY': 29.75,
      'ILS': 3.65,
      'AED': 3.67,
      'SAR': 3.75,
      'THB': 35.25,
      'MYR': 4.68,
      'PHP': 56.25,
      'IDR': 15750.0,
      'VND': 24500.0,
      'HKD': 7.82,
      'TWD': 31.85,
      'NZD': 1.65,
    };
    
    _availableRatesCount = fallbackRates.length;
    _isLiveData = false;
    
    if (_debugMode) {
      debugPrint('[CurrencyService] Fallback rates count: $_availableRatesCount (OFFLINE DATA)');
    }
    
    return fallbackRates;
  }

  // Currency metadata for better UX
  static const Map<String, Map<String, String>> currencyMetadata = {
    'USD': {'name': 'US Dollar', 'flag': '🇺🇸', 'country': 'United States'},
    'EUR': {'name': 'Euro', 'flag': '🇪🇺', 'country': 'European Union'},
    'GBP': {'name': 'British Pound', 'flag': '🇬🇧', 'country': 'United Kingdom'},
    'JPY': {'name': 'Japanese Yen', 'flag': '🇯🇵', 'country': 'Japan'},
    'CAD': {'name': 'Canadian Dollar', 'flag': '🇨🇦', 'country': 'Canada'},
    'AUD': {'name': 'Australian Dollar', 'flag': '🇦🇺', 'country': 'Australia'},
    'CHF': {'name': 'Swiss Franc', 'flag': '🇨🇭', 'country': 'Switzerland'},
    'CNY': {'name': 'Chinese Yuan', 'flag': '🇨🇳', 'country': 'China'},
    'INR': {'name': 'Indian Rupee', 'flag': '🇮🇳', 'country': 'India'},
    'BRL': {'name': 'Brazilian Real', 'flag': '🇧🇷', 'country': 'Brazil'},
    'KRW': {'name': 'South Korean Won', 'flag': '🇰🇷', 'country': 'South Korea'},
    'SGD': {'name': 'Singapore Dollar', 'flag': '🇸🇬', 'country': 'Singapore'},
    'MXN': {'name': 'Mexican Peso', 'flag': '🇲🇽', 'country': 'Mexico'},
    'RUB': {'name': 'Russian Ruble', 'flag': '🇷🇺', 'country': 'Russia'},
    'ZAR': {'name': 'South African Rand', 'flag': '🇿🇦', 'country': 'South Africa'},
    'NOK': {'name': 'Norwegian Krone', 'flag': '🇳🇴', 'country': 'Norway'},
    'SEK': {'name': 'Swedish Krona', 'flag': '🇸🇪', 'country': 'Sweden'},
    'DKK': {'name': 'Danish Krone', 'flag': '🇩🇰', 'country': 'Denmark'},
    'PLN': {'name': 'Polish Zloty', 'flag': '🇵🇱', 'country': 'Poland'},
    'CZK': {'name': 'Czech Koruna', 'flag': '🇨🇿', 'country': 'Czech Republic'},
    'HUF': {'name': 'Hungarian Forint', 'flag': '🇭🇺', 'country': 'Hungary'},
    'TRY': {'name': 'Turkish Lira', 'flag': '🇹🇷', 'country': 'Turkey'},
    'ILS': {'name': 'Israeli Shekel', 'flag': '🇮🇱', 'country': 'Israel'},
    'AED': {'name': 'UAE Dirham', 'flag': '🇦🇪', 'country': 'UAE'},
    'SAR': {'name': 'Saudi Riyal', 'flag': '🇸🇦', 'country': 'Saudi Arabia'},
    'THB': {'name': 'Thai Baht', 'flag': '🇹🇭', 'country': 'Thailand'},
    'MYR': {'name': 'Malaysian Ringgit', 'flag': '🇲🇾', 'country': 'Malaysia'},
    'PHP': {'name': 'Philippine Peso', 'flag': '🇵🇭', 'country': 'Philippines'},
    'IDR': {'name': 'Indonesian Rupiah', 'flag': '🇮🇩', 'country': 'Indonesia'},
    'VND': {'name': 'Vietnamese Dong', 'flag': '🇻🇳', 'country': 'Vietnam'},
    'HKD': {'name': 'Hong Kong Dollar', 'flag': '🇭🇰', 'country': 'Hong Kong'},
    'TWD': {'name': 'Taiwan Dollar', 'flag': '🇹🇼', 'country': 'Taiwan'},
    'NZD': {'name': 'New Zealand Dollar', 'flag': '🇳🇿', 'country': 'New Zealand'},
  };

  static Map<String, String> getCurrencyInfo(String code) {
    return currencyMetadata[code] ?? {'name': code, 'flag': '💱', 'country': 'Unknown'};
  }

  static String getLastUpdateTime() {
    if (_lastUpdate == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(_lastUpdate!);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static bool get isUsingCachedData => _cachedRates != null;
  static int get availableRatesCount => _availableRatesCount;
  static bool get isLiveData => _isLiveData;

  // Enhanced status information
  static String getDataSourceInfo() {
    if (_isLiveData) {
      return 'Live rates ($_availableRatesCount currencies)';
    } else {
      return 'Offline rates ($_availableRatesCount currencies)';
    }
  }

  static String getDetailedStatus() {
    final source = _isLiveData ? 'ExchangeRate-API' : 'Offline';
    final lastUpdate = getLastUpdateTime();
    return '$source • $_availableRatesCount rates • Updated $lastUpdate';
  }

  // Debug methods
  static String? get lastError => _lastError;
  
  static void enableDebugMode(bool enable) {
    _debugMode = enable;
    if (_debugMode) {
      debugPrint('[CurrencyService] Debug mode enabled');
    }
  }

  static Future<bool> testConnection() async {
    try {
      if (_debugMode) {
        debugPrint('[CurrencyService] Testing connection...');
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/USD'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      final isSuccessful = response.statusCode == 200;
      
      if (_debugMode) {
        debugPrint('[CurrencyService] Connection test result: ${isSuccessful ? 'SUCCESS' : 'FAILED'}');
        if (!isSuccessful) {
          debugPrint('[CurrencyService] Test failed with status: ${response.statusCode}');
        }
      }
      
      return isSuccessful;
    } catch (e) {
      if (_debugMode) {
        debugPrint('[CurrencyService] Connection test failed with exception: $e');
      }
      return false;
    }
  }

  static Map<String, dynamic> getDebugInfo() {
    return {
      'hasCache': _cachedRates != null,
      'cacheSize': _cachedRates?.length ?? 0,
      'availableRatesCount': _availableRatesCount,
      'isLiveData': _isLiveData,
      'lastUpdate': _lastUpdate?.toIso8601String(),
      'lastError': _lastError,
      'cacheValidDuration': _cacheValidDuration.inHours,
      'isUsingCachedData': isUsingCachedData,
      'apiUrl': _baseUrl,
      'dataSource': _isLiveData ? 'Live API' : 'Fallback',
    };
  }

  static void clearCache() {
    if (_debugMode) {
      debugPrint('[CurrencyService] Clearing cache');
    }
    _cachedRates = null;
    _lastUpdate = null;
    _lastError = null;
    _availableRatesCount = 0;
    _isLiveData = false;
  }

  static List<String> getAvailableCurrencies() {
    if (_cachedRates != null) {
      final currencies = _cachedRates!.keys.toList();
      currencies.sort();
      return currencies;
    }
    
    // Return fallback currency codes if no cached data
    return [
      'AED', 'AUD', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 
      'EUR', 'GBP', 'HKD', 'HUF', 'IDR', 'ILS', 'INR', 'JPY',
      'KRW', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 'RUB',
      'SAR', 'SEK', 'SGD', 'THB', 'TRY', 'TWD', 'USD', 'VND', 'ZAR'
    ];
  }
}
