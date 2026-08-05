import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _workoutReminders = true;
  bool _trainerMessages = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Lembretes de Treino'),
            subtitle: const Text('Avisos sobre horários e metas semanais'),
            value: _workoutReminders,
            onChanged: (val) => setState(() => _workoutReminders = val),
            activeColor: Theme.of(context).primaryColor,
          ),
          SwitchListTile(
            title: const Text('Mensagens do Personal'),
            subtitle: const Text('Receber notificações de mensagens diretas'),
            value: _trainerMessages,
            onChanged: (val) => setState(() => _trainerMessages = val),
            activeColor: Theme.of(context).primaryColor,
          ),
          SwitchListTile(
            title: const Text('Ofertas e Novidades'),
            subtitle: const Text('E-mails promocionais e eventos do GymApp'),
            value: _marketingEmails,
            onChanged: (val) => setState(() => _marketingEmails = val),
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}