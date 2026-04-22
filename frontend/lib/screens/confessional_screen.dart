import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/constants.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';
import '../widgets/message_bubble.dart';

class ConfessionalScreen extends StatefulWidget {
  const ConfessionalScreen({super.key});

  @override
  State<ConfessionalScreen> createState() => _ConfessionalScreenState();
}

class _ConfessionalScreenState extends State<ConfessionalScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [
    _Msg(Speaker.minos, 'Aprendiz. Declara el contrato que has roto.', '10:44'),
    _Msg(Speaker.aspirant, 'Abandoné el bloque de trabajo profundo. Cansancio.', '10:45'),
    _Msg(Speaker.minos,
        'El cansancio es sensación. La disciplina es elección. Te debes cuarenta y dos minutos. ¿Pagarás la deuda ahora o la diferirás?',
        '10:46'),
    _Msg(Speaker.aspirant, 'Diferir. Necesito descansar.', '10:46'),
  ];
  bool _typing = true;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(Speaker.aspirant, text, '10:47'));
      _input.clear();
      _typing = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(Routes.dashboard),
          icon: const Icon(Icons.close, size: 20),
        ),
        title: Row(
          children: [
            Text('Ψ', style: KairosTheme.serif(size: 18, color: KairosColors.bronze)),
            const SizedBox(width: 12),
            Text(Strings.minos, style: KairosTheme.mono(size: 13, color: KairosColors.bone, letterSpacing: 4)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            center: Alignment.topCenter,
            colors: [Color(0x336B1A1A), KairosColors.black],
          ),
        ),
        child: Column(
          children: [
            _CaseStrip(),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_typing ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_typing && i == _messages.length) return const TypingIndicator();
                  final m = _messages[i];
                  return MessageBubble(text: m.text, timestamp: m.time, speaker: m.speaker);
                },
              ),
            ),
            _InputBar(controller: _input, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final Speaker speaker;
  final String text;
  final String time;
  _Msg(this.speaker, this.text, this.time);
}

class _CaseStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: KairosColors.charcoal,
        border: Border(bottom: BorderSide(color: KairosColors.hairline, width: 1)),
      ),
      child: Text(
        Strings.confessionalCase,
        style: KairosTheme.mono(size: 9, color: KairosColors.bronze, letterSpacing: 3),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
      decoration: const BoxDecoration(
        color: KairosColors.ink,
        border: Border(top: BorderSide(color: KairosColors.hairline, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: KairosColors.bronzeLight,
              cursorWidth: 1,
              style: KairosTheme.serif(size: 18, color: KairosColors.bone, style: FontStyle.italic),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: Strings.confessPlaceholder,
                hintStyle: KairosTheme.serif(
                    size: 18, color: KairosColors.muted, style: FontStyle.italic, weight: FontWeight.w300),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.arrow_forward, color: KairosColors.bronze, size: 20),
          ),
        ],
      ),
    );
  }
}
