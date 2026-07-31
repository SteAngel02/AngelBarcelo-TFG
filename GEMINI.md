# Contexto del Proyecto: TFG - Gamificación RPG (Flutter/Firebase)

## 1. Stack Tecnológico y Entorno
- **Lenguaje:** Dart
- **Framework:** Flutter
- **Gestión de Estado e Inyección de Dependencias:** Provider.
- **Backend/Base de Datos:** Firebase (principalmente Firestore).
- **Entorno:** Este proyecto se desarrolla en el contexto de un Trabajo de Fin de Grado (TFG) académico.

## 2. Soporte Académico (Prioridad Media)
- Al proponer soluciones técnicas, prioriza una redacción sencilla y fácil de entender a menos que se diga lo contrario.
- Si la solución se basa en patrones de diseño de software reconocidos (ej. Repository, Singleton, Factory), menciónalos explícitamente para facilitar su posterior redacción en la memoria del TFG.
- Cuando sea relevante, sugiere fuentes académicas o documentación oficial de Flutter/Dart para fundamentar decisiones de diseño.

## 3. Arquitectura del Proyecto
El proyecto sigue un enfoque de Monolito Modular por Capas. Se debe respetar la separación de responsabilidades para mantener el código mantenible y testeable:
- **Presentation Layer:** Widgets de Flutter, pantallas y gestión de estado.
- **Domain Layer:** Contiene los modelos de datos (entidades) y la lógica de negocio central. Es independiente de Firebase.
- **Data Layer:** Implementación de repositorios (repository pattern), interacción con los SDKs de Firebase (Firestore, Auth, etc.).
Se usará una estructura específica, evita generar archivos fuera de esta estructura (exceptuando lógica común que irá en /lib/core):
lib/features/[nombre_feature]/
├── domain/        # Lógica pura (Entidades e Interfaces de Repositorios)
│   ├── [feature]_entity.dart
│   └── [feature]_repository.dart      # Interfaz abstracta (Contrato)
├── data/          # Implementación (Modelos y Repositorios concretos)
│   ├── [feature]_repository_impl.dart # Implementación concreta (e.g. Firebase)
│   └── [feature]_model.dart           # Modelo con factory FromFirestore y ToFirestore
├── presentation/  # Interfaz y Estado
    ├── screens/
    ├── widgets/
    └── [feature]_provider.dart        # Gestor de estado que comunica UI con la interfaz del repositorio

**Nota sobre la Orquestación de Lógica (Anti-patrón Fat UI):**
Para mantener la arquitectura limpia sin crear formalmente una capa de Casos de Uso (Use Cases), la orquestación que afecte a múltiples dominios (ej. al completar una misión, hay que darle recompensas al avatar) debe hacerse **siempre dentro de los Providers** (actuando como Application Services). Nunca se debe orquestar esta lógica directamente en los Widgets de la UI. Para ello, los Providers pueden recibir otros Providers por parámetro si necesitan invocar lógica cruzada.

**Modelo de Dominio Rico (Rich Domain Model):**
Se debe evitar el "Modelo Anémico" donde las entidades solo tienen variables y los Providers dictan toda la lógica.
1. **Lógica en Entidades:** Las reglas de negocio (ej. cómo aplicar las recompensas de una misión a un avatar, o si una misión debe borrarse al completarse) deben residir en métodos dentro de las `Entities` (`applyMisionRewards`, `setActiveAvatar`, etc.). Los Providers deben limitarse a llamar a estos métodos y persistir el resultado usando los Repositories.
2. **Polimorfismo:** Usa el polimorfismo en las entidades para evitar el uso excesivo de `if (objeto is Tipo)` en los Providers siempre que sea posible. Por ejemplo, define reglas de negocio abstractas en las clases base (como `bool get shouldDeleteOnComplete`) y sobrescríbelas en las subclases (`TodoEntity`).


## 4. Estructura de Clases y Modelo de Datos (Core)
A continuación se detalla la estructura lógica de las entidades principales del proyecto, basada en el diagrama de clases actual. Al generar código de modelos o repositorios, respeta estas relaciones y atributos.

### Entidades Principales y Relaciones
* **Usuario (User):**
    * **Atributos:** `userName`, `email`, `password`, `graveyard` (Lista de Avatares muertos).
    * **Métodos:** `agregarAvatar()`.
    * **Relaciones:** Un Usuario tiene una relación 1:1 con su avatar activo, y 0:* con los avatares de su cementerio. Agrupa de 0 a varias notificaciones.

* **Avatar:**
    * **Atributos:** `name`, `image` (ruta/path), `isAlive`, `health`, `coins`, `gems`, `level`, `titulos` (Lista de Strings), `completedRetos` (Lista de IDs de Retos completados).
    * **Métodos:** `die()`, `levelUp()`, `completeReto(String retoId)`.
    * **Relaciones:** Tiene exactamente 5 Atributos. Un avatar agrupa de 0 a varias misiones y de 0 a varias sendas. Se asocia con Recompensas ("puede canjear"), un avatar puede tener de 0 a varias recompensas. Guarda referencias a los Retos completados.

* **Atributo:**
    * **Atributos:** `Name`, `Description`, `Level`, `Exp`.
    * **Métodos:** `levelUp()`.
    * **Relaciones:** Asociado a la progresión del Avatar.

* **Retos:**
    * **Atributos:** `idUI`, `titulo`, `contenidoEducativo`, `pregunta`, `opciones` (Lista), `respuestaCorrecta`, `explicacionRespuesta`, `nivelRequerido`, `activo`.
    * **Métodos:** `checkAnswer()`.
    * **Relaciones:** Colección global (read-only para el usuario) gestionada por el administrador de la aplicación.

* **Sendas:**
    * **Atributos:** `isCompleted`, `stat` (enum), `name`, `description`, `gemsReward`.
    * **Métodos:** `complete()`.
    * **Relaciones:** Tiene una relación recursiva 1..* para subsendas. Puede agrupar de 0 a varios ToDos.

* **Recompensas:**
    * **Atributos:** `nombre`, `descripcion`, `coinType` (enum), `price`, `stock`.
    * **Métodos:** `buy()`, `delete()`.
    * **Relaciones:** Pueden ser canjeadas por un avatar.

* **Notificación:**
    * **Atributos:** `title`, `description`, `date`, `viewed`.
    * **Métodos:** `markAsViewed()`, `goToContent()`.
    * **Relaciones:** Pueden ser notifiadas a un usuario.

### Jerarquía de Misiones
* **<Abstract> Mision:** Clase base para todas las misiones.
    * **Atributos:** `isCompleted`, `stat` (enum), `visible`, `name`, `description`, `difficulty`, `coinReward`.
    * **Métodos:** `complete()`, `edit()`.
    * **Subclases Concretas:**
        * **Diaria:** Misión de frecuencia diaria.
        * **Periodica:** Misión con periodicidad específica. Atributos: `Periodicity`, `isForever`, `goal`.
        * **Todo:** Misión de tipo lista de tareas.
        * **Castigo:** Misión con penalizaciones.