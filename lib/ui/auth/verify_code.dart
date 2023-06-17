import 'package:fibauth/ui/posts/post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/utils.dart';
import '../../widgets/round_button.dart';

class VerifyCode extends StatefulWidget {
  final String verificationId;
  const VerifyCode({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  bool loading = false;
  final List<TextEditingController> codeControllers = [
    for (int i = 0; i < 6; i++) TextEditingController(),
  ];
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _startListeningForCode();
  }

  void _startListeningForCode() {
    final _smsCode = codeControllers.map((controller) => controller.text).join();
    final _autoVerifiedPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (_smsCode.isNotEmpty || _autoVerifiedPhone == null) {
      return;
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: _smsCode,
    );

    setState(() {
      loading = true;
    });

    _signInWithCredential(credential);
  }

  void _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await auth.signInWithCredential(credential);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PostScreen()));
    } catch (e) {
      setState(() {
        loading = false;
      });
      Utils().toastMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 80),
            Text(
              'Enter 6 digit code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 6; i++)
                  SizedBox(
                    width: 40,
                    child: TextFormField(
                      controller: codeControllers[i],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && i != 5) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.isEmpty && i != 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 80),
            RoundButton(
              title: 'Verify',
              loading: loading,
              onTap: () async {
                setState(() {
                  loading = true;
                });
                final verificationCode = codeControllers.map((controller) => controller.text).join();
                final credential = PhoneAuthProvider.credential(
                  verificationId: widget.verificationId,
                  smsCode: verificationCode,
                );
                _signInWithCredential(credential);
              },
            ),
          ],
        ),
      ),
    );
  }
}
