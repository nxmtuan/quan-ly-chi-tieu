import 'package:flutter/widgets.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';

class GoogleWebSignInButton extends StatelessWidget {
  const GoogleWebSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final plugin = GoogleSignInPlatform.instance;

    if (plugin is! GoogleSignInPlugin) {
      return const SizedBox.shrink();
    }

    return plugin.renderButton(
      configuration: GSIButtonConfiguration(
        type: GSIButtonType.standard,
        theme: GSIButtonTheme.outline,
        size: GSIButtonSize.large,
        text: GSIButtonText.signin,
        shape: GSIButtonShape.pill,
        logoAlignment: GSIButtonLogoAlignment.left,
        minimumWidth: 180,
      ),
    );
  }
}
