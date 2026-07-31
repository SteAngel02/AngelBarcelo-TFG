import 'package:flutter/material.dart';
import '../../domain/sendas_entity.dart';
import 'senda_card_widget.dart';

class SendaListWidget extends StatelessWidget {
  final List<SendaEntity> sendas;
  final String avatarId;

  const SendaListWidget({
    super.key,
    required this.sendas,
    required this.avatarId,
  });

  @override
  Widget build(BuildContext context) {
    final activeSendas = sendas.where((s) => !s.isCompleted).toList();
    final completedSendas = sendas.where((s) => s.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...activeSendas.map((senda) => SendaCardWidget(senda: senda)),

        if (completedSendas.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Títulos adquiridos',
              style: TextStyle(
                color: Colors.purpleAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...completedSendas.map((senda) => SendaCardWidget(senda: senda)),
        ],
      ],
    );
  }
}
