import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/src/utils/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaSendEmail extends StatefulWidget {
  final String? redirectUrl;

  const SupaSendEmail({Key? key, this.redirectUrl}) : super(key: key);

  @override
  State<SupaSendEmail> createState() => _SupaSendEmailState();
}

class _SupaSendEmailState extends State<SupaSendEmail> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  SupabaseAuthUi supaAuth = SupabaseAuthUi();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !EmailValidator.validate(_email.text)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.email),
              border: OutlineInputBorder(),
              hintText: 'Enter your email',
            ),
            controller: _email,
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            child: const Text(
              'Send Reset Email',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              try {
                await supaAuth.sendResetPasswordEmail(_email.text);
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      title: Text('Success!'),
                      contentTextStyle: TextStyle(
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
                if (!mounted) return;
                Navigator.popAndPushNamed(context, widget.redirectUrl ?? '');
              } on GoTrueException catch (error) {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(error.message),
                      contentTextStyle: const TextStyle(
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                );
              } catch (error) {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      title: Text('Unexpeted error has occured'),
                      contentTextStyle: TextStyle(
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                );
              }
              setState(() {
                _email.text = '';
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
