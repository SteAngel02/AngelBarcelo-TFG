# ⚛️ Quantum Habits

> **Diseño y desarrollo de una aplicación de gamificación de hábitos con fines educativos: Caso de estudio en computación cuántica.**
> 
> *Trabajo Fin de Grado — Grado en Ingeniería Informática (Tecnologías de la Información)*  
> **Escuela Superior de Ingeniería Informática de Albacete — Universidad de Castilla-La Mancha (UCLM)**  
> **Autor:** Ángel Barceló Parada ([@SteAngel02](https://github.com/SteAngel02))  
> **Tutores:** Llanos Vergara Picazo, Gabriel Sebastián Rivera  

---

## 📌 Índice
- [Visión General y Motivación](#-visión-general-y-motivación)
- [✨ Características Principales](#-características-principales)
- [🎮 Gameplay Loop & Gamificación](#-gameplay-loop--gamificación)
- [🧬 Caso de Estudio: Píldoras Cuánticas](#-caso-de-estudio-píldoras-cuánticas)
- [🛠️ Arquitectura y Stack Tecnológico](#️-arquitectura-y-stack-tecnológico)
- [📐 Estructura del Proyecto](#-estructura-del-proyecto)
- [📊 Evaluación de Usabilidad (ISO/IEC 25062)](#-evaluación-de-usabilidad-isoiec-25062)
- [🚀 Instalación y Despliegue](#-instalación-y-despliegue)

---

## 💡 Visión General y Motivación

En la era digital actual, las plataformas de entretenimiento y redes sociales compiten activamente por la atención del usuario mediante algoritmos de recomendación intensivos y mecanismos de *scroll infinito*, lo que ha mermado la capacidad de atención sostenida y la tolerancia al esfuerzo postergado a largo plazo.

**Quantum Habits** nace para invertir esta dinámica: utiliza las técnicas de diseño de comportamiento de los videojuegos (*Behavioral Game Design*) para transformar la procrastinación en compromiso. A través de un sistema de gestión de hábitos, tareas y proyectos a largo plazo, el progreso personal del usuario en el mundo real se traduce directamente en la evolución de su avatar virtual.

Asimismo, incorpora una vertiente educativa mediante **píldoras formativas interactivas sobre computación y mecánica cuántica**, desbloqueables según el avance del usuario.

---

## ✨ Características Principales

- 👤 **Creación y Evolución del Avatar:** Encapsula el progreso del usuario mediante un avatar virtual personalizable con nivel global, barra de vida y 5 atributos clave (*Fuerza, Inteligencia, Constitución, Destreza y Sabiduría*).
- 📋 **Gestión Polimórfica de Misiones:**
  - 🔄 **Diarias:** Rutinas de cumplimiento cotidiano con reinicio automático.
  - 📅 **Periódicas:** Hábitos programables a intervalos específicos (ej. cada 3 días) con o sin meta de repeticiones.
  - ✅ **To-Do's:** Tareas puntuales de un solo uso.
  - ⚠️ **Castigos:** Acciones a evitar que restan vidas al avatar en caso de incumplimiento.
- 🗺️ **Sendas de Progreso (Proyectos a Largo Plazo):** Agrupaciones jerárquicas y recursivas de subtareas y subsendas. Al completarlas, otorgan **Gemas** (moneda exclusiva) y **Títulos Honoríficos** equipables.
- 🏪 **Tienda de Recompensas Autogestionada:** Espacio donde el usuario define y canjea sus propios incentivos del mundo real utilizando **Monedas** u **Oportunidades/Gemas**.
- 💀 **Mecánica de Aversión a la Pérdida y Cementerio:** La pérdida de todas las vidas provoca la muerte permanente del avatar. El progreso histórico se conserva en un **Cementerio de Avatares** interactivo.

---

## 🎮 Gameplay Loop & Gamificación

El sistema está diseñado bajo los principios de las **Cuatro Leyes del Cambio de Conducta** (*James Clear*) y el modelo **Octalysis** (*Yu-kai Chou*), activando motores de motivación como *Progreso*, *Sentido de Propiedad* y *Aversión a la Pérdida*:

```
   [ RUTINA REAL ] ──► Completa hábito / tarea en su día a día
          │
          ▼
   [ RECOMPENSA APP ] ──► Ganancia de EXP + Monedas + Atributos
          │
          ▼
   [ DESBLOQUEO ] ──► Sube de nivel ──► Consigue Intentos de Reto
          │
          ▼
   [ APRENDIZAJE ] ──► Completa Píldora Cuántica ──► Sube Atributos a elección
          │
          ▼
   [ INCENTIVO REAL ] ──► Canjea Monedas/Gemas en la Tienda Personalizada
```

---

## 🧬 Caso de Estudio: Píldoras Cuánticas

A medida que el avatar sube de nivel global, el usuario obtiene **Oportunidades** para acceder a retos de divulgación científica sobre **Computación y Mecánica Cuántica**:

1. 📖 **Lección Formativa:** Explicación concisa y accesible de principios fundamentales (Superposición, Entrelazamiento, Puertas Cuánticas, Qubits, etc.).
2. ❓ **Test de Evaluación:** Preguntas de opción múltiple para validar la comprensión.
3. 🏆 **Recompensa Adaptativa:** Al acertar, el usuario recibe **50 EXP globales** y puede elegir libremente qué atributo específico incrementar en +1 nivel, permitiendo reequilibrar su perfil.

---

## 🛠️ Arquitectura y Stack Tecnológico

El proyecto está desarrollado bajo un modelo **Monolito Modular por Capas** (*Clean Architecture + Feature-First + Rich Domain Model*):

- **Lenguaje:** [Dart](https://dart.dev/) (v3.x)
- **Framework Cross-Platform:** [Flutter](https://flutter.dev/) (v3.x)
- **Gestión de Estado:** `Provider` (Inyección de dependencias y reactividad)
- **Backend as a Service:** [Google Firebase](https://firebase.google.com/)
  - **Cloud Firestore:** Base de datos NoSQL basada en documentos/colecciones.
  - **Firebase Auth:** Autenticación persistente de usuarios.
- **Visualización de Datos:** `radar_chart_plus` para gráficos de araña/pentágono de atributos.
- **Entorno e IA:** Google Antigravity IDE (Gemini 1.5/3.1 Pro para generación de boilerplate y refactorización guiada por `GEMINI.md`).

---

## 📐 Estructura del Proyecto

El código fuente aplica el patrón **Feature-First**, agrupando toda la lógica por módulos de funcionalidad en lugar de capas globales:

```text
lib/
├── core/                        # Utilidades compartidas, tema visual y rutas
└── features/                    # Módulos independientes de la aplicación
    ├── autenticacion/           # Registro e Inicio de Sesión
    ├── avatar/                  # Gestión de entidad Avatar, Cementerio y Atributos
    ├── misiones/                # Diarias, Periódicas, To-Do's y Castigos
    ├── sendas/                  # Proyectos jerárquicos y Títulos Honoríficos
    ├── tienda/                  # Catálogo de Recompensas y Canjeo
    └── retos/                   # Píldoras Formativas y Tests Cuánticos
        ├── domain/              # Entidades puras e interfaces de repositorios
        ├── data/                # Implementación con Firestore (Models & Repositories)
        └── presentation/        # Pantallas, Widgets y Providers
```

---

## 📊 Evaluación de Usabilidad (ISO/IEC 25062)

Se realizó una evaluación empírica con **9 participantes** de diversos perfiles demográficos y técnicos, evaluando efectividad, eficiencia y satisfacción mediante la escala **SUS (System Usability Scale)**:

| Métrica | Resultado |
| :--- | :---: |
| **Completitud Desasistida** | **88,89 %** |
| **Tiempo Medio de Ejecución** | **5 min 31 s** |
| **Puntuación Media SUS** | **90,56 / 100** (*Excelente / A+*) |

---

## 🚀 Instalación y Despliegue

### Requisitos Previos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.19.0`
- [Dart SDK](https://dart.dev/get-dart) `>=3.3.0`
- Dispositivo Android / Emulador (API 21 o superior)

### Pasos
1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/SteAngel007/QuantumHabits.git
   cd QuantumHabits
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase:**
   Asegúrate de vincular tu proyecto de Firebase agregando los archivos de configuración correspondientes (`google-services.json` para Android) en `android/app/`.

4. **Ejecutar en modo Debug:**
   ```bash
   flutter run
   ```
