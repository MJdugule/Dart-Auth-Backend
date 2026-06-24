import 'dart:math';
import 'package:dotenv/dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

///
class EmailService {
  // Config keys remain clean and private
  ///
   final env = DotEnv(includePlatformEnvironment: true)..load();
  static const _smtpUsername = 'apikey';
  //  String? get _sendGridApiKey => env['SEND_GRID_API'];
  //  String? get _verifiedSenderEmail => env['VERIFIED_EMAIL'] ; 

  /// Generate OTP
  String generateOtp() {
    final random = Random.secure();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  /// Send OTP to Email
  Future<bool> sendOtpEmail({
    required String email,
    required String name,
    required String otp,
  }) async {
    final smtpServer = SmtpServer(
      'smtp.sendgrid.net', 
      port: 465,           
      ssl: true,           
      username: _smtpUsername,
      password: env['SEND_GRID_API'],
    );
    
    final message = Message()
      ..from =  Address(env['VERIFIED_EMAIL']?? '', 'DART Backend')
      ..recipients.add(email)
      ..subject = 'Your Verification Code: $otp'
      ..html = '''
        <div style="font-family: Arial, sans-serif; padding: 20px; text-align: center;">
          <h2>Verify Your Account</h2>
          <p>Hello $name, use this one-time code to complete your verification step:</p>
          <h1 style="color: #2196F3; letter-spacing: 5px;">$otp</h1>
          <p style="color: #999; font-size: 12px;">Code will expire in 10 minutes.</p>
        </div>
      ''';

    try {
     await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }
}
