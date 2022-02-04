import 'package:flutter/material.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/modules/auth/forgotPassword/forgot_password_provider.dart';
import 'package:go_find_me/modules/auth/validators.dart';
import 'package:go_find_me/themes/padding.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/forgotten_password_code_confirmation.dart';
import 'package:provider/provider.dart';

class ForgotPasswordIdentitypage extends StatefulWidget {
  ForgotPasswordIdentitypage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordIdentitypage> createState() =>
      _ForgotPasswordIdentitypageState();
}

class _ForgotPasswordIdentitypageState extends State<ForgotPasswordIdentitypage>
    with InputDec {
  ForgotPasswordProvider _forgotPasswordProvider = ForgotPasswordProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _forgotPasswordProvider.stream.listen((event) {
        switch (event.state) {
          case ForgotPasswordEventState.error:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                event.data,
                style: ThemeTexTStyle.regular(color: ThemeColors.white),
              ),
              backgroundColor: ThemeColors.accent,
            ));
            break;
          case ForgotPasswordEventState.success:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ForgottenPasswordCodeConfirmation()));
            break;
          default:
            return;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.white,
      body: SafeArea(
        child: ChangeNotifierProvider(
            create: (_) => _forgotPasswordProvider,
            builder: (context, _) {
              return Consumer<ForgotPasswordProvider>(
                  builder: (context, model, _) {
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: ThemePadding.padBase * 2),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: ThemeColors.primary,
                            radius: 20,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "GoFindMe",
                            style: TextStyle(
                                color: ThemeColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Text(
                        "Please enter a registered email to receive a code to be able to update your password",
                        style: ThemeTexTStyle.regular(
                            color: ThemeColors.grey.withOpacity(0.5)),
                      ),
                      SizedBox(
                        height: ThemePadding.padBase * 1.5,
                      ),
                      model.lastEvent!.state == ForgotPasswordEventState.loading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: ThemeColors.primary,
                              ),
                            )
                          : Column(
                              children: [
                                Form(
                                  key: model.formKey,
                                  child: TextFormField(
                                    validator: (val) {
                                      return AuthValidators.isEmptyValidator(
                                          val!);
                                    },
                                    controller: model.emailFeld,
                                    decoration: inputDec(hint: "Email"),
                                  ),
                                ),
                                SizedBox(
                                  height: ThemePadding.padBase * 2,
                                ),
                                ThemeButton.longButtonPrim(
                                    text: "Send Code",
                                    onpressed: model.onSubmitEmail),
                              ],
                            ),
                    ],
                  ),
                );
              });
            }),
      ),
    );
  }
}
