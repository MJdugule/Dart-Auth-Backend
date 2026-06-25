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
      ..from = Address(
        (env['VERIFIED_EMAIL'] ?? '').trim(),
        'DartBackend',
      )
      ..recipients.add(email)
      ..subject = 'Your Verification Code: $otp'
      ..html =
          '''
        <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 500px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px;">
          <h2 style="color: #333; text-align: center;">Verify Your Account</h2>
          <p>Hello $name,</p>
          <p>Use this one-time verification code to complete your registration:</p>
          <div style="background: #f5f5f5; padding: 15px; text-align: center; border-radius: 4px; margin: 20px 0;">
            <h1 style="color: #2196F3; letter-spacing: 5px; margin: 0; font-size: 32px;">$otp</h1>
          </div>
          <p style="color: #666; font-size: 14px; line-height: 1.5;">Code will expire in 5 minutes.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
          <p style="color: #999; font-size: 12px; line-height: 1.5; text-align: center;">
            💡If you didn't initiate this request, kindly ignore this email.
          </p>
        </div>
      ''';

    try {
      // await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sends a welcome email
  Future<bool> sendWelcomeEmail({
    required String email,
    required String name,
  }) async {
    final smtpServer = SmtpServer(
      'smtp.sendgrid.net',
      port: 465,
      ssl: true,
      username: _smtpUsername,
      password: env['SEND_GRID_API'],
    );

    final message = Message()
      ..from = Address(
        (env['VERIFIED_EMAIL'] ?? '').trim(),
        'Dart Backend',
      )
      ..recipients.add(email)
      ..subject = 'Welcome to Dart Backend, $name! 🎉'
      ..html =
          '''
        <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 500px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px;">
          <div style="text-align: center; font-size: 40px; margin-bottom: 10px;">🎉</div>
          <h2 style="color: #333; text-align: center; margin-top: 0;">Welcome aboard!</h2>
          <p>Hello <strong>$name</strong>,</p>
          <p>Your account has been verified successfully.</p>
          <p>
            This project is an authentication backend built with <strong>Dart</strong>,
            focused on secure sign-up, login, OTP verification, and token-based sessions.
          </p>
          <p>
            We are actively building more capabilities, and there is much more to come,
            including stronger session controls, expanded auth workflows, and smoother
            developer integrations.
          </p>
          <p style="color: #666; font-size: 14px; line-height: 1.5;">
            Thanks for being an early part of the journey. Your support helps us shape
            what comes next.
          </p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
          <p style="color: #999; font-size: 11px; text-align: center;">
            Sent automatically by your Dart Auth Backend project.
          </p>
        </div>
      ''';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sends a goodbye email after a user deletes their account
  Future<bool> sendGoodbyeEmail({
    required String email,
    required String name,
  }) async {
    final smtpServer = SmtpServer(
      'smtp.sendgrid.net',
      port: 465,
      ssl: true,
      username: _smtpUsername,
      password: env['SEND_GRID_API'],
    );

    final message = Message()
      ..from = Address(
        (env['VERIFIED_EMAIL'] ?? '').trim(),
        'Dart Backend',
      )
      ..recipients.add(email)
      ..subject = 'We hate to see you go, $name'
      ..html =
          '''
        <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 500px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px;">
          <div style="text-align: center; font-size: 40px; margin-bottom: 10px;"></div>
          <h2 style="color: #333; text-align: center; margin-top: 0;">We hate to see you go</h2>
          <p>Hi <strong>$name</strong>,</p>
          <p>
            Your account deletion request has been received and processed successfully.
            We are truly sorry to see you leave.
          </p>
          <p>
            Here is what happens next:
          </p>
          <ul style="color: #555; font-size: 14px; line-height: 1.8;">
            <li>Your account has been <strong>deactivated immediately</strong> and you can no longer log in.</li>
            <li>All of your personal data, including your profile and activity history, will be <strong>permanently removed within 30 days</strong>.</li>
            <li>Any active sessions have been invalidated.</li>
          </ul>
          <p style="color: #666; font-size: 14px; line-height: 1.5;">
            If this was a mistake or you change your mind within the next 30 days,
            please contact our support team before your data is permanently erased.
          </p>
          <p style="color: #666; font-size: 14px;">
            This project is a <strong>Dart-powered authentication backend</strong> and we
            are continuously improving. We hope to see you back someday.
          </p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
          <p style="color: #999; font-size: 11px; text-align: center;">
            Sent automatically by your Dart Auth Backend project.
          </p>
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
