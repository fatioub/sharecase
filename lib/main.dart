import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/unit_category.dart';
import 'screens/settings_screen.dart';
import 'services/theme_service.dart';
import 'services/currency_service.dart';
import 'widgets/custom_dropdown.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = ThemeService();
  await themeService.loadThemeMode();
  runApp(UnivertApp(themeService: themeService));
}

class UnivertApp extends StatelessWidget {
  final ThemeService themeService;

  const UnivertApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeService,
      builder: (context, child) {
        return MaterialApp(
          title: 'Univert',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.materialThemeMode,
          home: UnitsListScreen(themeService: themeService),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class UnitsListScreen extends StatefulWidget {
  final ThemeService themeService;

  const UnitsListScreen({super.key, required this.themeService});

  @override
  State<UnitsListScreen> createState() => _UnitsListScreenState();
}

class _UnitsListScreenState extends State<UnitsListScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<UnitCategory> filteredCategories = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    filteredCategories = UnitCategory.getAllCategories();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCategories = UnitCategory.getAllCategories();
      } else {
        filteredCategories = UnitCategory.getAllCategories()
            .where((category) =>
                category.title.toLowerCase().contains(query.toLowerCase()) ||
                category.subtitle.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Units'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(themeService: widget.themeService),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Universal Unit Converter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Convert between ${UnitCategory.getAllCategories().fold(0, (sum, cat) => sum + cat.units.length)}+ units across ${UnitCategory.getAllCategories().length} categories',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search categories...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      onChanged: _filterCategories,
                    ),
                  ),
                ],
              ),
            ),
            // Categories List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 100 + (index * 50)),
                    curve: Curves.easeOutBack,
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => 
                                  ConversionScreen(category: category),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  )),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Icon Container
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.title,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category.subtitle,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: category.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${category.units.length} units',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: category.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Chevron
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversionScreen extends StatefulWidget {
  final UnitCategory category;

  const ConversionScreen({super.key, required this.category});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> with TickerProviderStateMixin {
  String? fromUnit;
  String? toUnit;
  final TextEditingController _inputController = TextEditingController();
  String result = '';
  late AnimationController _resultAnimationController;
  late Animation<double> _resultScaleAnimation;
  bool _isLoadingCurrency = false;
  Map<String, double>? _currencyRates;
  List<String> _availableUnits = [];

  @override
  void initState() {
    super.initState();
    
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _resultScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.elasticOut,
    ));

    _initializeUnits();
  }

  Future<void> _initializeUnits() async {
    if (widget.category.name == 'Currency') {
      setState(() => _isLoadingCurrency = true);
      try {
        // Load available currencies from API
        _availableUnits = await UnitCategory.getAvailableCurrencies();
        _currencyRates = await CurrencyService.getExchangeRates();
        
        // Set default units
        fromUnit = _availableUnits.contains('USD') ? 'USD' : _availableUnits.first;
        toUnit = _availableUnits.contains('EUR') ? 'EUR' : 
                (_availableUnits.length > 1 ? _availableUnits[1] : _availableUnits.first);
      } catch (e) {
        // Use fallback on error
        _availableUnits = await UnitCategory.getAvailableCurrencies();
        fromUnit = 'USD';
        toUnit = 'EUR';
      } finally {
        setState(() => _isLoadingCurrency = false);
      }
    } else {
      // Use static units for non-currency categories
      _availableUnits = widget.category.units;
      fromUnit = _availableUnits.first;
      toUnit = _availableUnits.length > 1 ? _availableUnits[1] : _availableUnits.first;
    }
    
    _inputController.addListener(_convertValue);
  }

  @override
  void dispose() {
    _resultAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrencyRates() async {
    setState(() => _isLoadingCurrency = true);
    try {
      _currencyRates = await CurrencyService.getExchangeRates();
      // Refresh available currencies in case new ones are added
      _availableUnits = await UnitCategory.getAvailableCurrencies();
    } catch (e) {
      // Keep existing rates and units on error
    } finally {
      if (mounted) {
        setState(() => _isLoadingCurrency = false);
        _convertValue();
      }
    }
  }

  void _convertValue() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() => result = '');
      return;
    }

    final value = double.tryParse(input);
    if (value == null) {
      setState(() => result = 'Invalid input');
      return;
    }

    double converted = _performConversion(value, fromUnit!, toUnit!);
    setState(() {
      result = _formatResult(converted);
    });
    
    _resultAnimationController.reset();
    _resultAnimationController.forward();
  }

  double _performConversion(double value, String from, String to) {
    switch (widget.category.name) {
      case 'Length': return _convertLength(value, from, to);
      case 'Weight': return _convertWeight(value, from, to);
      case 'Temperature': return _convertTemperature(value, from, to);
      case 'Currency': return _convertCurrency(value, from, to);
      case 'Area': return _convertArea(value, from, to);
      case 'Volume': return _convertVolume(value, from, to);
      case 'Speed': return _convertSpeed(value, from, to);
      case 'Time': return _convertTime(value, from, to);
      default: return value;
    }
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(value < 1 ? 6 : 4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  double _convertLength(double value, String from, String to) {
    double meters;
    switch (from) {
      case 'Meter': meters = value; break;
      case 'Kilometer': meters = value * 1000; break;
      case 'Mile': meters = value * 1609.34; break;
      case 'Foot': meters = value * 0.3048; break;
      case 'Inch': meters = value * 0.0254; break;
      case 'Centimeter': meters = value * 0.01; break;
      case 'Millimeter': meters = value * 0.001; break;
      case 'Yard': meters = value * 0.9144; break;
      default: meters = value;
    }
    switch (to) {
      case 'Meter': return meters;
      case 'Kilometer': return meters / 1000;
      case 'Mile': return meters / 1609.34;
      case 'Foot': return meters / 0.3048;
      case 'Inch': return meters / 0.0254;
      case 'Centimeter': return meters / 0.01;
      case 'Millimeter': return meters / 0.001;
      case 'Yard': return meters / 0.9144;
      default: return meters;
    }
  }

  double _convertWeight(double value, String from, String to) {
    double grams;
    switch (from) {
      case 'Gram': grams = value; break;
      case 'Kilogram': grams = value * 1000; break;
      case 'Pound': grams = value * 453.592; break;
      case 'Ounce': grams = value * 28.3495; break;
      case 'Ton': grams = value * 1000000; break;
      case 'Stone': grams = value * 6350.29; break;
      default: grams = value;
    }
    switch (to) {
      case 'Gram': return grams;
      case 'Kilogram': return grams / 1000;
      case 'Pound': return grams / 453.592;
      case 'Ounce': return grams / 28.3495;
      case 'Ton': return grams / 1000000;
      case 'Stone': return grams / 6350.29;
      default: return grams;
    }
  }

  double _convertTemperature(double value, String from, String to) {
    double celsius;
    switch (from) {
      case 'Celsius': celsius = value; break;
      case 'Fahrenheit': celsius = (value - 32) * 5 / 9; break;
      case 'Kelvin': celsius = value - 273.15; break;
      default: celsius = value;
    }
    switch (to) {
      case 'Celsius': return celsius;
      case 'Fahrenheit': return celsius * 9 / 5 + 32;
      case 'Kelvin': return celsius + 273.15;
      default: return celsius;
    }
  }

  double _convertCurrency(double value, String from, String to) {
    if (_currencyRates == null) return value;
    
    final fromRate = _currencyRates![from] ?? 1.0;
    final toRate = _currencyRates![to] ?? 1.0;
    
    // Convert to USD first, then to target currency
    final usdValue = value / fromRate;
    return usdValue * toRate;
  }

  double _convertArea(double value, String from, String to) {
    double sqMeters;
    switch (from) {
      case 'Square Meter': sqMeters = value; break;
      case 'Square Kilometer': sqMeters = value * 1000000; break;
      case 'Square Mile': sqMeters = value * 2589988.11; break;
      case 'Acre': sqMeters = value * 4046.86; break;
      case 'Hectare': sqMeters = value * 10000; break;
      case 'Square Foot': sqMeters = value * 0.092903; break;
      default: sqMeters = value;
    }
    switch (to) {
      case 'Square Meter': return sqMeters;
      case 'Square Kilometer': return sqMeters / 1000000;
      case 'Square Mile': return sqMeters / 2589988.11;
      case 'Acre': return sqMeters / 4046.86;
      case 'Hectare': return sqMeters / 10000;
      case 'Square Foot': return sqMeters / 0.092903;
      default: return sqMeters;
    }
  }

  double _convertVolume(double value, String from, String to) {
    double liters;
    switch (from) {
      case 'Liter': liters = value; break;
      case 'Milliliter': liters = value / 1000; break;
      case 'Gallon': liters = value * 3.78541; break;
      case 'Cup': liters = value * 0.236588; break;
      case 'Pint': liters = value * 0.473176; break;
      case 'Quart': liters = value * 0.946353; break;
      case 'Fluid Ounce': liters = value * 0.0295735; break;
      default: liters = value;
    }
    switch (to) {
      case 'Liter': return liters;
      case 'Milliliter': return liters * 1000;
      case 'Gallon': return liters / 3.78541;
      case 'Cup': return liters / 0.236588;
      case 'Pint': return liters / 0.473176;
      case 'Quart': return liters / 0.946353;
      case 'Fluid Ounce': return liters / 0.0295735;
      default: return liters;
    }
  }

  double _convertSpeed(double value, String from, String to) {
    double mps;
    switch (from) {
      case 'Meter/Second': mps = value; break;
      case 'Kilometer/Hour': mps = value / 3.6; break;
      case 'Mile/Hour': mps = value * 0.44704; break;
      case 'Knot': mps = value * 0.514444; break;
      case 'Foot/Second': mps = value * 0.3048; break;
      default: mps = value;
    }
    switch (to) {
      case 'Meter/Second': return mps;
      case 'Kilometer/Hour': return mps * 3.6;
      case 'Mile/Hour': return mps / 0.44704;
      case 'Knot': return mps / 0.514444;
      case 'Foot/Second': return mps / 0.3048;
      default: return mps;
    }
  }

  double _convertTime(double value, String from, String to) {
    double seconds;
    switch (from) {
      case 'Second': seconds = value; break;
      case 'Minute': seconds = value * 60; break;
      case 'Hour': seconds = value * 3600; break;
      case 'Day': seconds = value * 86400; break;
      case 'Week': seconds = value * 604800; break;
      case 'Month': seconds = value * 2629746; break;
      case 'Year': seconds = value * 31556952; break;
      default: seconds = value;
    }
    switch (to) {
      case 'Second': return seconds;
      case 'Minute': return seconds / 60;
      case 'Hour': return seconds / 3600;
      case 'Day': return seconds / 86400;
      case 'Week': return seconds / 604800;
      case 'Month': return seconds / 2629746;
      case 'Year': return seconds / 31556952;
      default: return seconds;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if units are not initialized yet
    if (fromUnit == null || toUnit == null || _availableUnits.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.category.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: widget.category.name == 'Currency' ? [
          if (_isLoadingCurrency)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadCurrencyRates,
            ),
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Main Conversion Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Unit Selection Column (changed from Row to Column)
                    Column(
                      children: [
                        _buildUnitSelector('From', fromUnit!, (value) {
                          setState(() => fromUnit = value);
                          _convertValue();
                        }),
                        const SizedBox(height: 16),
                        // Swap Button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.category.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.category.color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                final temp = fromUnit;
                                fromUnit = toUnit;
                                toUnit = temp;
                              });
                              _convertValue();
                            },
                            icon: Icon(
                              Icons.swap_vert,
                              color: widget.category.color,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildUnitSelector('To', toUnit!, (value) {
                          setState(() => toUnit = value);
                          _convertValue();
                        }),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Input Field
                    TextField(
                      controller: _inputController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter value',
                        hintText: '0',
                        suffixText: fromUnit,
                        suffixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: widget.category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Result Container
                    ScaleTransition(
                      scale: _resultScaleAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.category.color.withOpacity(0.1),
                              widget.category.color.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.category.color.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Result',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              result.isEmpty ? '0' : result,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: widget.category.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (result.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                toUnit!,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: widget.category.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Additional Info
            if (widget.category.name == 'Currency') ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CurrencyService.isLiveData ? Icons.public : Icons.offline_bolt,
                          color: CurrencyService.isLiveData 
                              ? Colors.green 
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            CurrencyService.getDataSourceInfo(),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyService.getDetailedStatus(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelector(String label, String selectedUnit, ValueChanged<String> onChanged) {
    return CustomDropdown(
      label: label,
      selectedValue: _availableUnits.contains(selectedUnit) ? selectedUnit : _availableUnits.first,
      items: _availableUnits,
      onChanged: onChanged,
      color: widget.category.color,
      isCurrency: widget.category.name == 'Currency',
    );
  }

  String _getCurrencyName(String code) {
    if (widget.category.name == 'Currency') {
      return CurrencyService.getCurrencyInfo(code)['name'] ?? code;
    }
    return code;
  }
}
