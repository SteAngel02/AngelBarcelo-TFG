import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/reto_entity.dart';
import '../../../avatar/presentation/avatar_provider.dart';

enum RetoStep { intro, lesson, question, result }

class RetoFlowScreen extends StatefulWidget {
  final RetoEntity reto;
  final bool isCompleted;

  const RetoFlowScreen({
    super.key,
    required this.reto,
    required this.isCompleted,
  });

  @override
  State<RetoFlowScreen> createState() => _RetoFlowScreenState();
}

class _RetoFlowScreenState extends State<RetoFlowScreen> {
  RetoStep _currentStep = RetoStep.intro;
  int? _selectedOptionIndex;
  bool? _isCorrect;
  bool _hasAcceptedChallenge = false;

  bool get _canPop {
    // Si ya está completado, puede salir siempre
    if (widget.isCompleted) return true;
    // Si no ha aceptado el reto todavía, puede salir
    if (!_hasAcceptedChallenge) return true;
    // Si ya terminó de contestar, puede salir
    if (_currentStep == RetoStep.result) return true;
    // En caso contrario (está en lección o pregunta habiendo gastado punto), requiere confirmación
    return false;
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A38),
        title: const Text(
          '¿Abandonar el reto?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Si te retiras no recuperarás tu oportunidad.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cierra el dialog
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el dialog
              Navigator.of(context).pop(); // Sale de la pantalla del reto
            },
            child: const Text(
              'Retirarme',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _onAcceptChallenge() async {
    final avatarProvider = context.read<AvatarProvider>();
    if (!widget.isCompleted) {
      final success = await avatarProvider.acceptReto();
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No tienes Puntos de Reto suficientes.'),
            backgroundColor: Colors.redAccent.shade700,
          ),
        );
        return;
      }
      setState(() {
        _hasAcceptedChallenge = true;
      });
    }
    setState(() {
      _currentStep = RetoStep.lesson;
    });
  }

  void _onSubmitAnswer() async {
    if (_selectedOptionIndex == null) return;

    final isCorrect = _selectedOptionIndex == widget.reto.respuestaCorrecta;
    setState(() {
      _isCorrect = isCorrect;
      _currentStep = RetoStep.result;
    });

    if (isCorrect && !widget.isCompleted) {
      await context.read<AvatarProvider>().completeReto(widget.reto.id);
    }
  }

  void _showRewardModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2A38),
          title: const Text(
            'Elige un Atributo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tu respuesta correcta te otorga un punto de atributo y 50 exp globales. ¿Qué estadística quieres mejorar?',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ...[
                {'display': 'Fuerza', 'internal': 'fuerza'},
                {'display': 'Inteligencia', 'internal': 'inteligencia'},
                {'display': 'Constitución', 'internal': 'constitucion'},
                {'display': 'Destreza', 'internal': 'destreza'},
                {'display': 'Sabiduría', 'internal': 'sabiduria'},
              ].map((stat) {
                return ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.greenAccent),
                  title: Text(stat['display']!, style: const TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.of(dialogContext).pop(); // Cierra el dialog usando su context
                    await context.read<AvatarProvider>().claimRetoReward(stat['internal']!);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Has mejorado tu ${stat['display']} y ganado 50 EXP!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(); // Sale de la pantalla del reto usando el context externo
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntroStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.science, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 24),
          Text(
            widget.reto.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _onAcceptChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Aceptar reto',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.isCompleted
                ? 'No te costará ninguna oportunidad pero tampoco te dará ninguna recompensa'
                : 'Perderás 1 oportunidad',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: widget.isCompleted
                  ? Colors.grey
                  : Colors.grey.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A38),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book, color: Colors.blueAccent),
                    SizedBox(width: 12),
                    Text(
                      'Lección',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  widget.reto.contenidoEducativo,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = RetoStep.question;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Estoy listo',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
          ),
          child: Text(
            widget.reto.pregunta,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: widget.reto.opciones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final isSelected = _selectedOptionIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedOptionIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blueAccent.withOpacity(0.2)
                        : const Color(0xFF1E2A38),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blueAccent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.blueAccent : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.reto.opciones[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _selectedOptionIndex != null ? _onSubmitAnswer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            disabledBackgroundColor: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Contestar',
            style: TextStyle(
              fontSize: 20,
              color: _selectedOptionIndex != null
                  ? Colors.white
                  : Colors.white38,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultStep() {
    final isSuccess = _isCorrect ?? false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          isSuccess ? Icons.emoji_events : Icons.sentiment_dissatisfied,
          size: 100,
          color: isSuccess ? Colors.amber : Colors.grey,
        ),
        const SizedBox(height: 24),
        Text(
          isSuccess ? '¡Enhorabuena!' : '¡Qué pena! Más suerte la próxima vez.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isSuccess ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        if (isSuccess) ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade900.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.yellow),
                    SizedBox(width: 8),
                    Text(
                      'Explicación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.reto.explicacionRespuesta,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 48),
        if (isSuccess && !widget.isCompleted)
          ElevatedButton(
            onPressed: _showRewardModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              disabledBackgroundColor: Colors.grey.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Canjear recompensas',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Volver',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_currentStep) {
      case RetoStep.intro:
        content = _buildIntroStep();
        break;
      case RetoStep.lesson:
        content = _buildLessonStep();
        break;
      case RetoStep.question:
        content = _buildQuestionStep();
        break;
      case RetoStep.result:
        content = _buildResultStep();
        break;
    }

    return PopScope(
      canPop: _canPop,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121A22),
        appBar: AppBar(
          title: Text('Reto ${widget.reto.idUI}'),
          backgroundColor: const Color(0xFF1E2A38),
          foregroundColor: Colors.white,
        ),
        body: Padding(padding: const EdgeInsets.all(24.0), child: content),
      ),
    );
  }
}
