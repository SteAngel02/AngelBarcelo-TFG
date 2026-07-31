class RetoEntity {
  final String id;
  final int idUI;
  final String titulo;
  final String contenidoEducativo;
  final String pregunta;
  final List<String> opciones;
  final int respuestaCorrecta;
  final String explicacionRespuesta;
  final int nivelRequerido;
  final bool activo;

  RetoEntity({
    required this.id,
    required this.idUI,
    required this.titulo,
    required this.contenidoEducativo,
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrecta,
    required this.explicacionRespuesta,
    required this.nivelRequerido,
    required this.activo,
  });

  /// Regla de negocio pura: Evalúa si la respuesta dada es correcta.
  bool checkAnswer(int selectedIndex) {
    return selectedIndex == respuestaCorrecta;
  }
}
