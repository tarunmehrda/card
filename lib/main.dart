import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

String street = "";
String city = "";
String country = "";
String zipcode = "";

class Address {
  final String street;
  final String city;
  final String zipcode;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.zipcode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '123 Main St',
      city: json['city'] ?? 'Metropolis',
      zipcode: json['zipcode'] ?? '10001',
      country: json['country'] ?? 'United States',
    );
  }
}

class PaymentModeScreen extends StatefulWidget {
  @override
  _PaymentModeScreenState createState() => _PaymentModeScreenState();
}

class _PaymentModeScreenState extends State<PaymentModeScreen>
    with TickerProviderStateMixin {
  String selectedPaymentMode = 'card';
  bool isHidden = true;
  bool isCardFrozen = true; // New freeze state
  Address? address;

  // Multiple animation controllers for complex animations
  late AnimationController _mainController;
  late AnimationController _cardController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;
  late AnimationController _freezeController;
  late AnimationController _pulseController;

  // Multiple animations
  late Animation<double> _slideAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _buttonBounceAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _freezeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    fetchAddress();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Main controller for overall page animations
    _mainController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    // Card-specific animations
    _cardController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Button animations
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Background particle animation
    _backgroundController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    // Freeze/unfreeze animation
    _freezeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Continuous pulse animation
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    _cardRotationAnimation = Tween<double>(begin: 0.1, end: 0.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    _buttonBounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.bounceOut),
    );

    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _freezeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _freezeController, curve: Curves.easeInOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Color(0xFF1A1A1A),
      end: Color(0xFF0A1A2A),
    ).animate(_backgroundController);

    _cardSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack));
  }

  void _startAnimations() {
    _mainController.forward();
    _buttonController.forward();
    _backgroundController.repeat();
    _pulseController.repeat(reverse: true);

    Future.delayed(Duration(milliseconds: 300), () {
      _cardController.forward();
    });

    if (isCardFrozen) {
      _freezeController.forward();
    }
  }

  void _toggleFreeze() {
    setState(() {
      isCardFrozen = !isCardFrozen;
    });

    if (isCardFrozen) {
      _freezeController.forward();
    } else {
      _freezeController.reverse();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _cardController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    _freezeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> fetchAddress() async {
    try {
      final response = await http.get(
        Uri.parse('https://fakerapi.it/api/v2/addresses?_quantity=1'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            street = data['data'][0]['street'] ?? '123 Main St';
            city = data['data'][0]['city'] ?? 'Metropolis';
            zipcode = data['data'][0]['zipcode'] ?? '10001';
            country = data['data'][0]['country'] ?? 'United States';
          });
        }
      } else {
        _setFallbackAddress();
      }
    } catch (e) {
      print('Error fetching address: $e');
      _setFallbackAddress();
    }
  }

  void _setFallbackAddress() {
    setState(() {
      street = '789 Bank St';
      city = 'Transaction City';
      zipcode = '10003';
      country = 'United States';
    });
  }

  static const TextStyle headerTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.8,
  );

  String _getCardNumber(int index) {
    const List<String> digits = ['8124', '4212', '3456', '7890'];
    return digits[index];
  }

  void _navigateToCardDetails() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) =>
            CardDetailsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0A0A),
                _colorAnimation.value ?? Color(0xFF1A1A1A),
                Color(0xFF0A0A0A),
              ],
              stops: [0.0, _backgroundAnimation.value, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: ParticlePainter(_backgroundAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildFreezeButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: _toggleFreeze,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isCardFrozen ? Colors.blue[600] : Colors.orange[600],
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (isCardFrozen ? Colors.blue : Colors.orange)
                        .withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCardFrozen ? Icons.ac_unit : Icons.lock_open,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    isCardFrozen ? 'Frozen' : 'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [Colors.white, Colors.blue[300]!],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Select Payment Mode',
                                      style: headerTextStyle,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Choose your preferred payment method to\nmake secure transactions.',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedPaymentMode == 'card')
                              _buildFreezeButton(),
                          ],
                        ),
                        SizedBox(height: 40),
                        AnimatedBuilder(
                          animation: _buttonBounceAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonBounceAnimation.value,
                              child: Row(
                                children: [
                                  _buildPaymentModeButton(
                                      'pay', 'Pay Now', Icons.qr_code_scanner),
                                  SizedBox(width: 16),
                                  _buildPaymentModeButton(
                                      'card', 'Card Pay', Icons.credit_card),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 40),
                        Expanded(
                          child: selectedPaymentMode == 'card'
                              ? _buildAnimatedCard()
                              : _buildQRSection(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildPaymentModeButton(String mode, String label, IconData icon) {
    bool isSelected = selectedPaymentMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: mode == 'pay'
                      ? [Colors.green[400]!, Colors.green[600]!]
                      : [Colors.red[400]!, Colors.red[600]!],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[700]!,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (mode == 'pay' ? Colors.green : Colors.red)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard() {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_cardScaleAnimation, _cardRotationAnimation, _freezeAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: _cardSlideAnimation,
          child: Transform.scale(
            scale: _cardScaleAnimation.value,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_cardRotationAnimation.value)
                ..rotateX(_cardRotationAnimation.value * 0.5),
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: isCardFrozen ? null : _navigateToCardDetails,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width:
                            min(251, MediaQuery.of(context).size.width * 0.74),
                        height:
                            min(384, MediaQuery.of(context).size.height * 0.51),
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isCardFrozen
                                ? [Color(0xFF1A2A3A), Color(0xFF2A3A4A)]
                                : [Color(0xFF1A1A1A), Color(0xFF3A2A2A)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isCardFrozen ? Colors.blue : Colors.red)
                                  .withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: _buildCardContent(),
                      ),
                      if (isCardFrozen) _buildFrozenOverlay(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.red[400]!, Colors.red[600]!],
              ).createShader(bounds),
              child: Text(
                'YOLO',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1)
                  ],
                ),
              ),
              child: Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
        SizedBox(height: 28),
        // Card number section
        Column(
          children: List.generate(4, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 300),
                    style: GoogleFonts.robotoMono(
                      color: isCardFrozen && !isHidden && i >= 2
                          ? Colors.blue[300]!
                          : Colors.white,
                      fontSize: 17,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w500,
                    ),
                    child: Text(
                      (isHidden && i >= 2) || (isCardFrozen && i >= 2)
                          ? '••••'
                          : _getCardNumber(i),
                    ),
                  ),
                  if (i == 2)
                    GestureDetector(
                      onTap: isCardFrozen
                          ? null
                          : () => setState(() => isHidden = !isHidden),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCardFrozen
                              ? Colors.grey.withOpacity(0.3)
                              : Colors.red.withOpacity(0.2),
                        ),
                        child: Icon(
                          isHidden ? Icons.visibility_off : Icons.visibility,
                          size: 15,
                          color: isCardFrozen ? Colors.grey : Colors.red[400],
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 14),
        if (!isCardFrozen)
          Row(
            children: [
              Icon(Icons.copy, size: 15, color: Colors.red[400]),
              SizedBox(width: 8),
              Text(
                'Copy Details',
                style: GoogleFonts.poppins(
                  color: Colors.red[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCardInfo('VALID THRU', '12/25'),
            _buildCardInfo('CVV', isHidden || isCardFrozen ? '•••' : '123'),
          ],
        ),
        SizedBox(height: 14),
        if (!isCardFrozen) _buildAddressInfo(),
      ],
    );
  }

  Widget _buildCardInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BILLING ADDRESS',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '$street\n$city, $zipcode\n$country',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFrozenOverlay() {
    return AnimatedBuilder(
      animation: _freezeAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withOpacity(0.3 * _freezeAnimation.value),
                  Colors.cyan.withOpacity(0.2 * _freezeAnimation.value),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.ac_unit,
                    size: 60 * _freezeAnimation.value,
                    color: Colors.blue[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Card Frozen',
                    style: TextStyle(
                      color: Colors.blue[300],
                      fontSize: 20 * _freezeAnimation.value,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap "Frozen" to unfreeze',
                    style: TextStyle(
                      color: Colors.blue[200],
                      fontSize: 14 * _freezeAnimation.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQRSection() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.green[300]!, Colors.green[500]!],
                  ).createShader(bounds),
                  child: Text(
                    'Scan QR Code to Pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Open your camera and scan the\nQR code to make instant payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111111), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.qr_code, 'Yolo Pay', 1, isSelected: true),
          _buildNavItem(Icons.percent_outlined, 'Offers', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {bool isSelected = false}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(12),
            decoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.red[400]!, Colors.red[600]!],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent particles

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationValue * 100) %
          size.height;
      final radius = random.nextDouble() * 2 + 1;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CardDetailsPage extends StatefulWidget {
  @override
  _CardDetailsPageState createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage>
    with SingleTickerProviderStateMixin {
  bool isHidden = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  String _getCardNumber(int index) {
    const List<String> digits = ['8124', '4212', '3456', '7890'];
    return digits[index];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _animation.value)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Card Details',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: min(
                              250, MediaQuery.of(context).size.width * 0.75),
                          height: min(
                              380, MediaQuery.of(context).size.height * 0.52),
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A1A1A),
                                Color(0xFF3A2A2A),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Colors.red[400]!,
                                        Colors.red[600]!
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'YOLO',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 19,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1)
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.credit_card,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 28),
                              Column(
                                children: List.generate(4, (i) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isHidden && i >= 2
                                              ? '••••'
                                              : _getCardNumber(i),
                                          style: GoogleFonts.robotoMono(
                                            color: Colors.white,
                                            fontSize: 17,
                                            letterSpacing: 2.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (i == 2)
                                          GestureDetector(
                                            onTap: () => setState(
                                                () => isHidden = !isHidden),
                                            child: AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 200),
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    Colors.red.withOpacity(0.2),
                                              ),
                                              child: Icon(
                                                isHidden
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                size: 15,
                                                color: Colors.red[400],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(Icons.copy,
                                      size: 15, color: Colors.red[400]),
                                  SizedBox(width: 8),
                                  Text(
                                    'Copy Details',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red[400],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'VALID THRU',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '12/25',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CVV',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        isHidden ? '•••' : '123',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BILLING ADDRESS',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '$street\n$city, $zipcode\n$country',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yolo Pay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF0A0A0A),
      ),
      home: PaymentModeScreen(),
    );
  }
}
