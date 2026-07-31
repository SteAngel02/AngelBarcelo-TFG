import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/reto_entity.dart';

class RetoModel extends RetoEntity {
  RetoModel({
    required super.id,
    required super.idUI,
    required super.titulo,
    required super.contenidoEducativo,
    required super.pregunta,
    required super.opciones,
    required super.respuestaCorrecta,
    required super.explicacionRespuesta,
    required super.nivelRequerido,
    required super.activo,
  });

  factory RetoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RetoModel(
      id: doc.id,
      idUI: data['idUI'] as int? ?? 0,
      titulo: data['titulo'] as String? ?? '',
      contenidoEducativo: data['contenidoEducativo'] as String? ?? '',
      pregunta: data['pregunta'] as String? ?? '',
      opciones: List<String>.from(data['opciones'] ?? []),
      respuestaCorrecta: data['respuestaCorrecta'] as int? ?? 0,
      explicacionRespuesta: data['explicacionRespuesta'] as String? ?? '',
      nivelRequerido: data['nivelRequerido'] as int? ?? 1,
      activo: data['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'idUI': idUI,
      'titulo': titulo,
      'contenidoEducativo': contenidoEducativo,
      'pregunta': pregunta,
      'opciones': opciones,
      'respuestaCorrecta': respuestaCorrecta,
      'explicacionRespuesta': explicacionRespuesta,
      'nivelRequerido': nivelRequerido,
      'activo': activo,
    };
  }
}
