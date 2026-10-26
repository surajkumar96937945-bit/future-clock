import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const FutureClockApp());
}

class FutureClockApp extends StatelessWidget {
  const FutureClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0D14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF00E676),
        ),
      ),
      home: const MainClockScreen(),
    );
  }
}

class MainClockScreen extends StatefulWidget {
  const MainClockScreen({super.key});

  @override
  State<MainClockScreen> createState() => _MainClockScreenState();
}

class _MainClockScreenState extends State<MainClockScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late Timer _timer;
  DateTime _now = DateTime.now();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animController.dispose();
    super.dispose();
  }

  Widget _buildDigitalClock() {
    String hours = _now.hour.toString().padLeft(2, '0');
    String minutes = _now.minute.toString().padLeft(2, '0');
    String seconds = _now.second.toString().padLeft(2, '0');

    IconData periodIcon;
    Color iconColor;
    String periodText;

    if (_now.hour >= 5 && _now.hour < 12) {
      periodIcon = Icons.wb_sunny_rounded;
      iconColor = const Color(0xFFFFB300);
      periodText = 'GOOD MORNING';
    } else if (_now.hour >= 12 && _now.hour < 17) {
      periodIcon = Icons.wb_sunny_outlined;
      iconColor = const Color(0xFFFF9100);
      periodText = 'GOOD AFTERNOON';
    } else if (_now.hour >= 17 && _now.hour < 20) {
      periodIcon = Icons.wb_twilight_rounded;
      iconColor = const Color(0xFFFF5252);
      periodText = 'GOOD EVENING';
    } else {
      periodIcon = Icons.nightlight_round;
      iconColor = const Color(0xFF8C9EFF);
      periodText = 'GOOD NIGHT';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              double offset = math.sin(_animController.value * 2 * math.pi) * 12;
              return Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.12),
                    border: Border.all(color: iconColor.withOpacity(0.35), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.25),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(periodIcon, size: 48, color: iconColor),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            periodText,
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$hours:$minutes:$seconds',
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w200,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String title, double value, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressScreen() {
    double secProgress = (_now.second + (_now.millisecond / 1000.0)) / 60.0;
    double minProgress = (_now.minute + (_now.second / 60.0)) / 60.0;
    double hourProgress = (_now.hour % 12 + (_now.minute / 60.0)) / 12.0;
    double dayProgress = ((_now.hour * 3600) + (_now.minute * 60) + _now.second) / 86400.0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
        child: Column(
          children: [
            _buildProgressBar(
              'SECONDS PROGRESS',
              secProgress,
              '${_now.second}s / 60s',
              const Color(0xFF00E5FF),
            ),
            _buildProgressBar(
              'MINUTES PROGRESS',
              minProgress,
              '${_now.minute}m / 60m',
              const Color(0xFF00E676),
            ),
            _buildProgressBar(
              'HOUR PROGRESS (12H)',
              hourProgress,
              '${_now.hour % 12}h / 12h',
              const Color(0xFFFFD600),
            ),
            _buildProgressBar(
              'DAY PROGRESS (24H)',
              dayProgress,
              '${_now.hour}h ${_now.minute}m / 24h',
              const Color(0xFFFF5252),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingWidget(String title, double percentage, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 14),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: (percentage / 100.0).clamp(0.0, 1.0),
                strokeWidth: 8,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLifePercentageScreen() {
    int passedDayMs = (_now.hour * 3600 * 1000) +
        (_now.minute * 60 * 1000) +
        (_now.second * 1000) +
        _now.millisecond;
    double dayPct = (passedDayMs / (24 * 3600 * 1000)) * 100.0;

    double weekPct = (((_now.weekday - 1) * 86400 * 1000 + passedDayMs) /
            (7 * 86400 * 1000)) *
        100.0;

    int totalDaysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    double monthPct = (((_now.day - 1) * 86400 * 1000 + passedDayMs) /
            (totalDaysInMonth * 86400 * 1000)) *
        100.0;

    bool isLeapYear = (_now.year % 4 == 0 && _now.year % 100 != 0) || (_now.year % 400 == 0);
    int totalDaysInYear = isLeapYear ? 366 : 365;
    int dayOfYear = int.parse(
        DateTime(_now.year, _now.month, _now.day)
            .difference(DateTime(_now.year, 1, 1))
            .inDays
            .toString()) + 1;
    double yearPct = (((dayOfYear - 1) * 86400 * 1000 + passedDayMs) /
            (totalDaysInYear * 86400 * 1000)) *
        100.0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRingWidget("DAY USED", dayPct, const Color(0xFF00E676)),
                _buildRingWidget("WEEK USED", weekPct, const Color(0xFF00E5FF)),
              ],
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRingWidget("MONTH USED", monthPct, const Color(0xFFD500F9)),
                _buildRingWidget("YEAR USED", yearPct, const Color(0xFFFF9100)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateScreen() {
    String year = _now.year.toString();
    String month = _now.month.toString().padLeft(2, '0');
    String day = _now.day.toString().padLeft(2, '0');

    const List<String> weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    String weekdayName = weekdays[_now.weekday - 1];

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animController.value * 2 * math.pi,
                child: SizedBox(
                  width: 290,
                  height: 290,
                  child: CustomPaint(
                    painter: _DesignerCirclePainter(),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_animController.value * 2 * math.pi,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withOpacity(0.15),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'CURRENT DATE',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '$year-$month-$day',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                weekdayName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00E5FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDigitalClock(),
      _buildProgressScreen(),
      _buildLifePercentageScreen(),
      _buildDateScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Future Clock',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF10141E),
        elevation: 0,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF10141E),
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_rounded),
            label: 'Digital',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_bottom_rounded),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline_rounded),
            label: 'Life %',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Date',
          ),
        ],
      ),
    );
  }
}

class _DesignerCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const int totalDots = 24;
    for (int i = 0; i < totalDots; i++) {
      double angle = (i * 2 * math.pi) / totalDots;
      double x1 = center.dx + (radius - 6) * math.cos(angle);
      double y1 = center.dy + (radius - 6) * math.sin(angle);
      double x2 = center.dx + radius * math.cos(angle);
      double y2 = center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
