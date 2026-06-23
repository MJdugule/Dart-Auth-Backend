import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

///
class EmailService {
  static const _smtpUsername = 'apikey';
  static const _sendGridApiKey = 'your send grid api key';
  static const _verifiedSenderEmail = 'senders email'; 

  /// Generate OTP
  static String generateOtp() {
    final random = Random();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  /// Send OTP to Email
  static Future<bool> sendOtpEmail({
    required String email,
    required String name,
    required String otp
  }) async {
     final smtpServer = SmtpServer(
      'smtp.sendgrid.net', 
      port: 465,           
      ssl: true,           
      username: _smtpUsername,
      password: _sendGridApiKey,
    );
    
  final message = Message()
      ..from = const Address(_verifiedSenderEmail,)
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
      // final sendReport = await send(message, smtpServer);
      // print('SMTP Delivery Success! Tracking report: $sendReport');
      return true;
    } catch (e) {
      // print('SMTP Delivery Engine Failure Exception: $e');
      return false;
    }
  }
}
