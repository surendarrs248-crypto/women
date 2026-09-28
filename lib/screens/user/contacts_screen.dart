import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/sms_fallback_service.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  late final TextEditingController _profileName;
  late final TextEditingController _profilePhone;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _profileName = TextEditingController(text: state.profile.name);
    _profilePhone = TextEditingController(text: state.profile.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _profileName.dispose();
    _profilePhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
      children: [
        const H1('Guardians'),
        const SizedBox(height: 4),
        const Sub('Add trusted contacts and choose one primary contact.'),
        const SizedBox(height: 12),
        SakhiCard(
          tight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Prepare emergency alerts'),
              const SizedBox(height: 4),
              const Sub(
                'Allow location and, on Android, direct SMS before an emergency.',
              ),
              const SizedBox(height: 10),
              SakhiButton(
                'Enable emergency permissions',
                style: BtnStyle.ghost,
                block: true,
                onTap: () async {
                  final granted =
                      await SmsFallbackService().requestPermissions();
                  if (!context.mounted) return;
                  context.read<AppState>().toast(granted
                      ? 'Emergency permissions are ready'
                      : 'Some emergency permissions were not granted');
                },
              ),
            ],
          ),
        ),
        SakhiCard(
          child: state.contacts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Sub('No guardians yet. Add one below.'),
                )
              : Column(
                  children: [
                    for (var i = 0; i < state.contacts.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Avatar(initials(state.contacts[i].n)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.contacts[i].n,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.contacts[i].p,
                                    style: kMono.copyWith(
                                      fontSize: 11.5,
                                      color: C.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Primary guardian',
                              onPressed: () => state.starContact(i),
                              icon: Icon(
                                state.contacts[i].star
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: state.contacts[i].star
                                    ? C.amber
                                    : C.faint,
                              ),
                            ),
                            IconBtn(
                              '☎',
                              tooltip: 'Call guardian',
                              onTap: () => state.launch(Uri(
                                scheme: 'tel',
                                path: telSafe(state.contacts[i].p),
                              )),
                            ),
                            IconBtn(
                              '×',
                              tooltip: 'Remove guardian',
                              onTap: () => state.delContact(i),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        SakhiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Add guardian'),
              const SizedBox(height: 10),
              const Eyebrow('Name'),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. Amma'),
              ),
              const SizedBox(height: 11),
              const Eyebrow('Phone (with country code)'),
              const SizedBox(height: 6),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '+91 98765 43210'),
              ),
              const SizedBox(height: 11),
              SakhiButton(
                'Add to guardians',
                style: BtnStyle.amber,
                block: true,
                onTap: () {
                  state.addContact(_name.text, _phone.text);
                  _name.clear();
                  _phone.clear();
                },
              ),
            ],
          ),
        ),
        SakhiCard(
          tight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Your profile'),
              const SizedBox(height: 10),
              const Eyebrow('Name shared in alerts'),
              const SizedBox(height: 6),
              TextField(
                controller: _profileName,
                onChanged: state.setProfileName,
              ),
              const SizedBox(height: 11),
              const Eyebrow('Your phone'),
              const SizedBox(height: 6),
              TextField(
                controller: _profilePhone,
                keyboardType: TextInputType.phone,
                onChanged: state.setProfilePhone,
              ),
            ],
          ),
        ),
      ],
    );
  }
}