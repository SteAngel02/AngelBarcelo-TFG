import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/login/presentation/auth_provider.dart';
import '../features/avatar/presentation/avatar_provider.dart';
import '../features/avatar/presentation/screens/create_avatar_screen.dart';
import '../features/avatar/presentation/widgets/avatar_inicio_widget.dart';
import '../features/misiones/presentation/mision_provider.dart';
import '../features/misiones/presentation/screens/create_mision_screen.dart';
import '../features/misiones/domain/mision_entity.dart';
import '../features/misiones/presentation/widgets/lista_diarias_widget.dart';
import '../features/misiones/presentation/widgets/lista_todo_widget.dart';
import '../features/misiones/presentation/widgets/lista_periodicas_widget.dart';
import '../features/misiones/presentation/widgets/lista_castigos_widget.dart';
import '../features/tienda/presentation/tienda_panel_widget.dart';
import '../features/tienda/presentation/screens/create_recompensa_screen.dart';
import '../features/retos/presentation/screens/lista_retos_screen.dart';
import '../features/sendas/presentation/sendas_provider.dart';
import '../features/sendas/presentation/widgets/senda_list_widget.dart';
import '../features/sendas/presentation/screens/create_senda_screen.dart';
import '../features/misiones/presentation/widgets/missed_misiones_dialog_widget.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  bool _isTiendaOpen = false;
  bool _isShowingMissedDialog = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAvatarIfNeeded();
    });
  }

  void _loadAvatarIfNeeded() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user != null && user.hasActiveAvatar && user.activeAvatarId != null) {
      final avatarProvider = context.read<AvatarProvider>();
      final misionProvider = context.read<MisionProvider>();
      final sendaProvider = context.read<SendaProvider>();

      if (avatarProvider.currentAvatar == null) {
        avatarProvider.loadAvatar(user.activeAvatarId!);
      }

      // Cargamos las misiones y sendas (los providers se encargan de no duplicar subscripciones)
      misionProvider.loadMisiones(user.activeAvatarId!);
      sendaProvider.loadSendas(user.activeAvatarId!);
    }
  }

  /// Añade misiones de prueba para poder testear el programa.
  /*
  void _seedMisiones(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user != null && user.activeAvatarId != null) {
      final misionProvider = context.read<MisionProvider>();

      final tiendaProvider = context.read<TiendaProvider>();

      final misionesSemilla = [
        DiariaEntity(
          id: '',
          name: 'Programar TFG',
          description:
              'Hacer al menos 1 hora de programación diaria para el TFG.',
          stat: StatType.inteligencia,
          difficulty: 'Normal',
          coinReward: 15,
        ),
        TodoEntity(
          id: '',
          name: 'Comprar pan',
          description:
              'Ir a la panadería de la esquina a comprar una barra de pan.',
          stat: StatType.fuerza,
          difficulty: 'Fácil',
          coinReward: 5,
        ),
        PeriodicaEntity(
          id: '',
          name: 'Ir al Gimnasio',
          description: 'Hacer deporte 3 veces a la semana.',
          stat: StatType.constitucion,
          difficulty: 'Difícil',
          coinReward: 30,
          periodicity: 3,
          isForever: false,
          goal: 3,
        ),
        CastigoEntity(
          id: '',
          name: 'Comer comida basura',
          description: 'Comer pizza, hamburguesas o patatas fritas.',
          stat: StatType.constitucion,
          difficulty: 'Normal',
          coinReward: 0,
          penaltyCoins: 5,
          penaltyHealth: 1, // Baja 1 de vida
        ),
      ];

      final recompensasSemilla = [
        RecompensaEntity(
          id: '',
          nombre: 'Ver un capítulo de serie',
          descripcion: 'Descansa y ve un capítulo de tu serie favorita.',
          coinType: CoinType.coins,
          price: 50,
          stock: -1, // Ilimitado
        ),
        RecompensaEntity(
          id: '',
          nombre: 'Comer un dulce',
          descripcion: 'Date un capricho y come ese dulce que tanto te gusta.',
          coinType: CoinType.coins,
          price: 30,
          stock: -1, // Ilimitado
        ),
        RecompensaEntity(
          id: '',
          nombre: 'Comprar un videojuego',
          descripcion: 'Cómprate ese juego de Steam que querías.',
          coinType: CoinType.gems,
          price: 5,
          stock: 1, // Sólo 1 vez
        ),
        RecompensaEntity(
          id: '',
          nombre: 'Día libre total',
          descripcion: 'Un día entero sin hacer absolutamente nada de provecho.',
          coinType: CoinType.gems,
          price: 10,
          stock: 1, // Sólo 1 vez
        ),
      ];

      for (var mision in misionesSemilla) {
        misionProvider.addMision(user.activeAvatarId!, mision);
      }

      for (var recompensa in recompensasSemilla) {
        tiendaProvider.addRecompensa(user.activeAvatarId!, recompensa);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Se han generado misiones y recompensas de prueba!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }*/

  /// Añade retos de prueba para Mecánica Cuántica temporalmente
  /*
  Future<void> _seedRetos(BuildContext context) async {
    final retosSemilla = [
      {
        "idUI": 1,
        "titulo": "El Principio de Superposición",
        "contenidoEducativo": "En mecánica cuántica, el principio de superposición establece que un sistema físico existe en todos sus estados teóricamente posibles simultáneamente hasta que es medido o interactúa con el entorno, momento en el que el estado 'colapsa'.",
        "pregunta": "¿Qué afirma el principio de superposición sobre un sistema antes de ser medido?",
        "opciones": [
          "Que solo existe en un único estado determinado.",
          "Que existe en todos sus estados posibles simultáneamente.",
          "Que su energía es siempre cero.",
          "Que no existe hasta que se mide."
        ],
        "respuestaCorrecta": 1,
        "explicacionRespuesta": "Exacto. Antes de la medición, un sistema cuántico se encuentra en una superposición de múltiples estados simultáneos.",
        "nivelRequerido": 1,
        "activo": true,
      },
      {
        "idUI": 2,
        "titulo": "El Gato de Schrödinger",
        "contenidoEducativo": "El Gato de Schrödinger es un experimento mental que ilustra la superposición cuántica. Un gato en una caja sellada con un mecanismo letal que depende de un evento cuántico está simultáneamente vivo y muerto hasta que se abre la caja.",
        "pregunta": "¿Qué ilustra el experimento mental del Gato de Schrödinger?",
        "opciones": [
          "Que los gatos tienen 7 vidas.",
          "La imposibilidad de medir la posición y la velocidad.",
          "La superposición de estados a nivel macroscópico.",
          "La teoría de la relatividad."
        ],
        "respuestaCorrecta": 2,
        "explicacionRespuesta": "Correcto. Schrödinger usó este experimento para mostrar lo paradójico que resulta aplicar la superposición cuántica a objetos macroscópicos.",
        "nivelRequerido": 1,
        "activo": true,
      },
      {
        "idUI": 3,
        "titulo": "El Entrelazamiento Cuántico",
        "contenidoEducativo": "El entrelazamiento cuántico es un fenómeno donde dos o más partículas se conectan de tal manera que el estado cuántico de una no se puede describir independientemente del de la otra, sin importar la distancia. Einstein lo llamó 'acción fantasmal a distancia'.",
        "pregunta": "¿Qué ocurre con dos partículas entrelazadas?",
        "opciones": [
          "Se repelen instantáneamente.",
          "Comparten un estado y la medición de una afecta a la otra al instante.",
          "Se convierten en una sola partícula más grande.",
          "Giran siempre en la misma dirección sin importar la influencia externa."
        ],
        "respuestaCorrecta": 1,
        "explicacionRespuesta": "¡Muy bien! Las partículas entrelazadas comparten un estado indivisible, y medir una determina el estado de la otra instantáneamente.",
        "nivelRequerido": 2,
        "activo": true,
      },
      {
        "idUI": 4,
        "titulo": "El Principio de Incertidumbre de Heisenberg",
        "contenidoEducativo": "El principio de incertidumbre establece que es imposible conocer simultáneamente y con precisión absoluta ciertas parejas de propiedades, como la posición y el momento (velocidad). Cuanto más preciso se mide una, más incierta es la otra.",
        "pregunta": "¿Cuáles son las dos propiedades que no se pueden medir simultáneamente con precisión absoluta según Heisenberg?",
        "opciones": [
          "Masa y Energía",
          "Posición y Momento",
          "Tiempo y Espacio",
          "Velocidad y Aceleración"
        ],
        "respuestaCorrecta": 1,
        "explicacionRespuesta": "Correcto. Conocer la posición exacta de una partícula hace que su momento (o velocidad) sea completamente incierto, y viceversa.",
        "nivelRequerido": 2,
        "activo": true,
      }
    ];

    try {
      final collection = FirebaseFirestore.instance.collection('Retos');
      for (var reto in retosSemilla) {
        final docRef = collection.doc();
        reto['id'] = docRef.id;
        await docRef.set(reto);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Se han generado retos de Mecánica Cuántica!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar retos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    // Leemos el estado de autenticación
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // Lógica de ruteo dinámico: Si está logueado pero NO tiene avatar activo
    if (user != null && !user.hasActiveAvatar) {
      return const CreateAvatarScreen();
    }

    final avatarProvider = context.watch<AvatarProvider>();
    final misionProvider = context.watch<MisionProvider>();
    final sendaProvider = context.watch<SendaProvider>();

    if (misionProvider.pendingMissedHearts > 0 && !_isShowingMissedDialog) {
      _isShowingMissedDialog = true;
      final heartsLost = misionProvider.consumePendingMissedHearts();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await showMissedMisionesDialog(context, heartsLost);
          if (mounted) {
            final avatarProvider = context.read<AvatarProvider>();
            final authProvider = context.read<AuthProvider>();
            await avatarProvider.modifyHealth(-heartsLost);
            if (avatarProvider.currentAvatar != null &&
                !avatarProvider.currentAvatar!.isAlive) {
              await authProvider.buryActiveAvatar();
            }
          }
        }
        _isShowingMissedDialog = false;
      });
    }

    final misiones = misionProvider.misiones;
    final diarias = misiones.whereType<DiariaEntity>().toList();
    final todo = misiones.whereType<TodoEntity>().toList();
    final periodicas = misiones.whereType<PeriodicaEntity>().toList();
    final castigos = misiones.whereType<CastigoEntity>().toList();
    final sendas = sendaProvider.sendas;

    return Scaffold(
      backgroundColor: const Color(0xFF121A22), // Fondo oscuro RPG
      /*appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            tooltip: 'Generar Retos Cuánticos',
            onPressed: () => _seedRetos(context),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Generar Misiones Semilla',
            onPressed: () => _seedMisiones(context),
          ),
        ],
      ),*/
      body: SafeArea(
        child: avatarProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : avatarProvider.currentAvatar == null
            ? const Center(
                child: Text(
                  "Cargando...",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = constraints.maxHeight;
                  final panelHeight = maxHeight * 0.70;
                  const tabHeight = 40.0;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Fondo Principal: Avatar y Misiones
                      Column(
                        children: [
                          AvatarInicioWidget(
                            avatar: avatarProvider.currentAvatar!,
                            userName: user?.userName ?? '',
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    'Misiones',
                                    style: TextStyle(
                                      color: _currentPage == 0
                                          ? Colors.amber
                                          : Colors.white54,
                                      fontSize: 18,
                                      fontWeight: _currentPage == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '•',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      1,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Text(
                                    'Sendas',
                                    style: TextStyle(
                                      color: _currentPage == 1
                                          ? Colors.cyanAccent
                                          : Colors.white54,
                                      fontSize: 18,
                                      fontWeight: _currentPage == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              children: [
                                // PÁGINA 1: MISIONES
                                misionProvider.isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ListaDiariasWidget(
                                              misiones: diarias,
                                              avatarId: user!.activeAvatarId!,
                                            ),
                                            ListaTodoWidget(
                                              misiones: todo,
                                              avatarId: user.activeAvatarId!,
                                            ),
                                            ListaPeriodicasWidget(
                                              misiones: periodicas,
                                              avatarId: user.activeAvatarId!,
                                            ),
                                            ListaCastigosWidget(
                                              misiones: castigos,
                                              avatarId: user.activeAvatarId!,
                                            ),
                                            // Espacio extra abajo para que la pestaña no tape la última misión
                                            const SizedBox(height: 120),
                                          ],
                                        ),
                                      ),
                                // PÁGINA 2: SENDAS
                                sendaProvider.isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : sendas.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "Aún no has creado ninguna senda.",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            SendaListWidget(
                                              sendas: sendas,
                                              avatarId: user!.activeAvatarId!,
                                            ),
                                            // Espacio extra abajo para que la pestaña no tape la última senda
                                            const SizedBox(height: 120),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // 2. Panel deslizante: Tienda (animado con Transform para máxima fluidez)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: panelHeight + tabHeight,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.fastOutSlowIn,
                          // Traslación vertical: si está cerrada, baja 'panelHeight' píxeles.
                          transform: Matrix4.translationValues(
                            0,
                            _isTiendaOpen ? 0 : panelHeight,
                            0,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Contenedor principal de la tienda
                              Positioned(
                                top: tabHeight,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E2A38),
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: TiendaPanelWidget(
                                    onClose: () {
                                      setState(() {
                                        _isTiendaOpen = false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              // La pestaña blanca triangular
                              Positioned(
                                top: _isTiendaOpen ? tabHeight : 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isTiendaOpen = !_isTiendaOpen;
                                      });
                                    },
                                    onVerticalDragUpdate: (details) {
                                      if (details.primaryDelta! < -5) {
                                        setState(() {
                                          _isTiendaOpen = true;
                                        });
                                      } else if (details.primaryDelta! > 5) {
                                        setState(() {
                                          _isTiendaOpen = false;
                                        });
                                      }
                                    },
                                    child: SizedBox(
                                      width: 80,
                                      height: tabHeight,
                                      child: CustomPaint(
                                        painter: _TrianglePainter(
                                          isDown: _isTiendaOpen,
                                        ),
                                        child: Align(
                                          alignment: _isTiendaOpen
                                              ? Alignment.topCenter
                                              : Alignment.bottomCenter,
                                          child: Padding(
                                            padding: _isTiendaOpen
                                                ? const EdgeInsets.only(
                                                    top: 2.0,
                                                  )
                                                : const EdgeInsets.only(
                                                    bottom: 2.0,
                                                  ),
                                            child: Icon(
                                              _isTiendaOpen
                                                  ? Icons.keyboard_arrow_down
                                                  : Icons.shopping_cart,
                                              color: Colors.black,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      // Botones flotantes (Misiones/Tienda a la izquierda, Retos a la derecha)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'fab_add_mision_recompensa',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      if (_isTiendaOpen) {
                        return const CreateRecompensaScreen();
                      } else if (_currentPage == 1) {
                        return const CreateSendaScreen();
                      } else {
                        return const CreateMisionScreen();
                      }
                    },
                  ),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            FloatingActionButton(
              heroTag: 'fab_lista_retos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListaRetosScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.grid_view, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter para dibujar la pestaña blanca triangular
class _TrianglePainter extends CustomPainter {
  final bool isDown;

  _TrianglePainter({this.isDown = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isDown) {
      path.moveTo(0, 0); // Arriba a la izquierda
      path.lineTo(
        size.width / 2,
        size.height,
      ); // Abajo en el centro (punta del triángulo)
      path.lineTo(size.width, 0); // Arriba a la derecha
    } else {
      path.moveTo(0, size.height); // Abajo a la izquierda
      path.lineTo(
        size.width / 2,
        0,
      ); // Arriba en el centro (punta del triángulo)
      path.lineTo(size.width, size.height); // Abajo a la derecha
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.isDown != isDown;
  }
}
