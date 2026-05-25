# Arquitectura de RPG Retro SNES - Secret of Evermore Style
## Documentación Técnica Completa

---

## 📋 Índice
1. [Descripción General](#descripción-general)
2. [Estructura de Carpetas](#estructura-de-carpetas)
3. [Arquitectura de Sistemas](#arquitectura-de-sistemas)
4. [Descripción de Componentes](#descripción-de-componentes)
5. [Flujo de Transición de Escenas](#flujo-de-transición-de-escenas)
6. [Guía de Extensión](#guía-de-extensión)
7. [Buenas Prácticas](#buenas-prácticas)
8. [Próximos Pasos](#próximos-pasos)

---

## 🎮 Descripción General

Este proyecto implementa una arquitectura **limpia, escalable y desacoplada** para un RPG de acción retro estilo Secret of Evermore.

### Principios de Arquitectura

```
┌─────────────────────────────────────────────────────┐
│           SINGLETON LAYER (AutoLoad)                 │
│  GameManager    │    SceneLoader    │   (Future)    │
│  - Estado global│    - Transiciones  │  - Audio Mgr  │
│  - Persistencia │    - Carga escenas │  - Input Mgr  │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│         CORE SYSTEMS LAYER                           │
│  SceneController  │  BattleCharacter  │  Encounter  │
│  - Lógica escenas │  - Stats combate  │  - Sistema  │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│          PRESENTATION LAYER                          │
│  UI Components  │  Animations  │  Visual Effects   │
└─────────────────────────────────────────────────────┘
```

### Ventajas de Esta Arquitectura

✅ **Desacoplamiento Total**: Las escenas no dependen una de otra
✅ **Reutilización**: Sistemas pueden usarse en múltiples escenas
✅ **Testeable**: Lógica separada de presentación
✅ **Escalable**: Fácil agregar nuevos enemigos, NPCs, etc.
✅ **Mantenible**: Código organizado y bien documentado

---

## 📁 Estructura de Carpetas

```
juego/
├── project.godot                  # Configuración de Godot
│
├── src/                           # Código fuente principal
│   ├── main.gd                    # Script bootstrap
│   │
│   ├── core/                      # Sistemas centrales
│   │   └── scene_loader.gd        # Gestor de transiciones
│   │
│   ├── managers/                  # Gestores globales
│   │   └── game_manager.gd        # Singleton principal
│   │
│   ├── scenes/                    # Escenas principales
│   │   ├── main.tscn              # Escena de inicio
│   │   ├── world_map/
│   │   │   ├── world_map.tscn    # Escena exploración
│   │   │   ├── world_map_controller.gd
│   │   │   ├── player.tscn       # Prefab jugador
│   │   │   └── enemy.tscn        # Prefab enemigo
│   │   └── battle/
│   │       ├── battle_scene.tscn  # Escena batalla
│   │       └── battle_controller.gd
│   │
│   ├── characters/                # Personajes
│   │   ├── player/
│   │   │   └── player_controller.gd
│   │   └── enemy/
│   │       └── enemy_controller.gd
│   │
│   ├── systems/                   # Sistemas de juego
│   │   └── battle_character.gd    # Datos de combate
│   │
│   └── ui/                        # Interfaz de usuario
│       └── battle_ui/
│           └── battle_ui.gd       # UI de batalla
│
└── assets/                        # Recursos (sprites, música, etc.)
    ├── maps/
    ├── music/
    └── sprites/
```

---

## 🏗️ Arquitectura de Sistemas

### 1. **GameManager (Singleton)**

**Responsabilidad**: Gestionar estado global del juego

```gdscript
# Datos persistentes del jugador
player_data: Dictionary = {
    "hp": 100,
    "max_hp": 100,
    "exp": 0,
    "level": 1,
    "gold": 0,
    "position": Vector2(100, 100)
}

# Datos del encuentro actual
current_encounter: Dictionary = {
    "enemies": [],
    "difficulty": 1,
    "rewards_exp": 0,
    "rewards_gold": 0
}
```

**Métodos Clave**:
- `start_encounter()` - Inicia batalla
- `end_encounter()` - Finaliza batalla
- `save_game()` / `load_game()` - Persistencia
- `get_player_data()` - Obtiene estado jugador

---

### 2. **SceneLoader (Singleton)**

**Responsabilidad**: Transiciones suaves entre escenas

```gdscript
enum TransitionType {
    FADE,           # Fade to black
    SLIDE_LEFT,     # Deslización izquierda
    SLIDE_RIGHT,    # Deslización derecha
    NONE            # Sin transición
}
```

**Características**:
- Manejo de transiciones SNES-style
- Carga asincrónica de escenas
- Prevención de duplicados
- Smooth fade in/out

---

### 3. **WorldMapController**

**Responsabilidad**: Gestionar escena de exploración

```
WorldMap
├── Player (PlayerController)
├── TileMap
├── Camera2D
├── AudioStreamPlayer (Música ambiental)
├── Enemy_1 (EnemyController)
├── Enemy_2 (EnemyController)
└── ...
```

**Características**:
- Instanciación del jugador
- Spawn dinámico de enemigos
- Cámara de seguimiento suave
- Música ambiental

---

### 4. **BattleController**

**Responsabilidad**: Sistema de combate completo

```
BattleScene
├── BattleBackground (ColorRect/Sprite)
├── Camera2D
├── AudioStreamPlayer (Música batalla)
├── BattleUI (Control)
│   ├── PlayerHUD
│   ├── EnemyInfoContainer
│   └── ActionMenu
└── [Characters datos en memoria]
```

**Flujo de Combate**:
1. Inicializar personajes
2. Calcular orden de turnos
3. Ejecutar acciones del jugador
4. IA de enemigos ataca
5. Verificar fin de batalla
6. Entregar recompensas

---

## 👥 Descripción de Componentes

### PlayerController

**Hereda de**: `CharacterBody2D`

```gdscript
# Movimiento
@export var speed: float = 100.0
@export var acceleration: float = 500.0

# Detección de colisiones
@onready var interaction_area = $InteractionArea

# Maneja:
# - Input de 8 direcciones
# - Movimiento suave
# - Animaciones contextuales
# - Detección de enemigos
```

**Animaciones Esperadas**:
```
idle_up, idle_down, idle_left, idle_right
walk_up, walk_down, walk_left, walk_right
```

---

### EnemyController

**Hereda de**: `CharacterBody2D`

```gdscript
# Propiedades
@export var enemy_type: String = "Slime"
@export var level: int = 1
@export var patrol_range: float = 100.0
@export var alert_distance: float = 150.0

# Comportamiento:
# 1. Patrulla entre dos puntos
# 2. Se alerta si detecta al jugador
# 3. Persigue si está en rango
# 4. Dispara encuentro si toca al jugador
```

**Máquina de Estados**:
```
PATRULLA ──(detectar jugador)──> ALERTA ──(toque)──> COMBATE
   ↑_______________________________|
        (jugador sale de rango)
```

---

### BattleCharacter

**Hereda de**: `RefCounted` (No es Node2D, es puro dato)

```gdscript
# Stats
var health: int
var max_health: int
var attack: int
var defense: int
var speed: int

# Métodos
func calculate_damage(target: BattleCharacter) -> int
func take_damage(damage: int) -> void
func is_defeated() -> bool
```

**Por qué RefCounted?**
- No necesita estar en el árbol de escena
- Se gestiona con referencias automáticas
- Perfecto para datos de combate
- Más eficiente que Node

---

## 🔄 Flujo de Transición de Escenas

### Flujo Completo: WorldMap → Batalla → WorldMap

```
┌─────────────────────────────────────────────────────────┐
│ 1. EXPLORACIÓN (WorldMap)                               │
│    - Jugador se mueve                                   │
│    - Enemigos patrullan                                 │
└─────────────────────────────────────────────────────────┘
                        ↓
            [Jugador toca enemigo]
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 2. DETECCIÓN (WorldMapController._on_interaction)       │
│    - Verificar colisión                                 │
│    - Guardar posición del jugador                       │
│    - Llamar EnemyController.trigger_encounter()        │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 3. TRANSICIÓN A BATALLA (GameManager.start_encounter) │
│    - is_transitioning = true                            │
│    - GameManager.scene_transition_started.emit()       │
│    - Fade out (0.5s)                                    │
│    - Cargar BattleScene                                 │
│    - Actualizar referencias                             │
│    - Fade in (0.5s)                                     │
│    - Emitir player_entered_battle                       │
│    - is_transitioning = false                           │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 4. COMBATE (BattleController)                           │
│    - Inicializar personajes                             │
│    - Crear UI                                            │
│    - Turno del jugador                                  │
│    - Turno de enemigos                                  │
│    - Repetir hasta fin                                  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 5. FIN DE BATALLA (BattleController._end_battle)      │
│    - Calcular recompensas                               │
│    - GameManager.end_encounter(victory, exp, loot)     │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 6. TRANSICIÓN A MUNDO (GameManager.end_encounter)      │
│    - Actualizar player_data (exp, gold)                │
│    - Verificar subida de nivel                         │
│    - Fade out batalla                                   │
│    - Cargar WorldMap                                    │
│    - Restaurar posición jugador                         │
│    - Restaurar HP jugador                               │
│    - Fade in                                            │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 7. DE VUELTA A EXPLORACIÓN                              │
│    - Jugador continúa su aventura                       │
└─────────────────────────────────────────────────────────┘
```

### Código de Ejemplo - Colisión

```gdscript
# PlayerController
func _on_interaction_area_entered(area: Area2D) -> void:
    if area.is_in_group("enemy"):
        # El enemigo dispara el encuentro
        area.trigger_encounter()

# EnemyController
func trigger_encounter() -> void:
    var enemy_data = {
        "type": enemy_type,
        "level": level,
        "health": health,
        "max_health": health,
    }
    # GameManager maneja todo desde aquí
    GameManager.start_encounter([enemy_data], level)
```

---

## 🚀 Guía de Extensión

### Agregar un Nuevo Enemigo

```gdscript
# 1. Crear prefab enemy_types/goblin.tscn
# 2. En enemy_controller.gd, cambiar @export values:

@export var enemy_type: String = "Goblin"
@export var health: int = 35
@export var attack: int = 8
```

### Agregar Habilidades Especiales

```gdscript
# En BattleCharacter
func get_special_abilities() -> Array:
    return [
        {"name": "Fireball", "mp_cost": 15, "damage": 25},
        {"name": "Heal", "mp_cost": 10, "healing": 20}
    ]

# En BattleController
func execute_ability(ability_name: String) -> void:
    match ability_name:
        "Fireball":
            var target = enemy_characters[target_index]
            target.take_damage(25)
        "Heal":
            player_character.restore_health(20)
```

### Agregar Sistema de Objetos

```gdscript
# En GameManager
var inventory: Dictionary = {
    "potion": 5,
    "ether": 2,
    "revive": 1
}

# En BattleUI
func use_item(item_name: String) -> void:
    match item_name:
        "potion":
            player_character.restore_health(50)
            GameManager.inventory["potion"] -= 1
```

### Agregar Estadísticas de Equipo

```gdscript
# En PlayerController
var equipment: Dictionary = {
    "weapon": "Iron Sword",  # +5 ATK
    "armor": "Leather Armor", # +3 DEF
    "accessory": "HP Ring"    # +20 MAX HP
}

func get_stat_bonuses() -> Dictionary:
    return {
        "attack": 5,
        "defense": 3,
        "max_hp": 20
    }
```

---

## ✨ Buenas Prácticas

### 1. **Nomenclatura**

```
✅ CORRECTO:
- player_controller.gd
- enemy_ai.gd
- battle_system.gd
- _on_area_entered()
- calculate_damage()

❌ INCORRECTO:
- PlayerController.gd
- EnemyAI.gd
- battleSystem.gd
- onAreaEntered()
- CalcDamg()
```

### 2. **Signals (Señales)**

```gdscript
# Buena práctica: Nombrar señales en pasado
signal player_died
signal battle_started
signal enemy_defeated

# Emitir desde código
battle_started.emit()

# Conectar con métodos débiles
enemy_defeated.connect(_on_enemy_defeated, CONNECT_ONE_SHOT)
```

### 3. **Comentarios**

```gdscript
## Descripción de función con documentación
## @param param1 Descripción
## @param param2 Descripción
## @return Tipo de retorno
func my_function(param1: String, param2: int) -> bool:
    # Comentario inline para lógica compleja
    var result = expensive_calculation()
    return result > 0
```

### 4. **Gestión de Memoria**

```gdscript
# ✅ CORRECTO: Liberar referencias
func _exit_tree() -> void:
    # Desconectar señales
    for signal_connection in get_signal_connections():
        disconnect(signal_connection.signal.get_name(), ...)
    
    # Liberar recursos
    if music_player:
        music_player.stop()

# ❌ INCORRECTO: Dejar referencias colgantes
# (Puede causar memory leaks)
```

### 5. **Estados y Máquinas de Estados**

```gdscript
# Para lógica compleja, usar enum
enum EnemyState {
    IDLE,
    PATROL,
    CHASE,
    ATTACK,
    DEAD
}

var current_state: EnemyState = EnemyState.IDLE

func _process(delta: float) -> void:
    match current_state:
        EnemyState.IDLE:
            _handle_idle(delta)
        EnemyState.PATROL:
            _handle_patrol(delta)
        EnemyState.CHASE:
            _handle_chase(delta)
        EnemyState.ATTACK:
            _handle_attack(delta)
        EnemyState.DEAD:
            _handle_dead(delta)
```

---

## 📈 Próximos Pasos Recomendados

### FASE 1: Fundamentos (Semana 1-2)
- [ ] Crear prefabs visuales (sprites del jugador/enemigos)
- [ ] Implementar animaciones básicas
- [ ] Crear un tilemap simple
- [ ] Probar movimiento y colisiones

### FASE 2: Combate Básico (Semana 2-3)
- [ ] Implementar sistema de turnos completo
- [ ] Añadir IA enemiga simple
- [ ] Crear UI visual para batalla
- [ ] Animaciones de ataque/defensa

### FASE 3: Contenido (Semana 3-4)
- [ ] 3-5 tipos de enemigos diferentes
- [ ] 2-3 mapas exploración
- [ ] Sistema de diálogo NPC
- [ ] Tienda de objetos

### FASE 4: Pulido (Semana 4-5)
- [ ] Efectos visuales (partículas, flashes)
- [ ] Sonido y música
- [ ] Menús (pausa, inventario, guardado)
- [ ] Cinemáticas introducción

### FASE 5: Expansión (Semana 5+)
- [ ] Boss fights con patrones especiales
- [ ] Habilidades especiales del jugador
- [ ] Sistema de magia/mana
- [ ] Jefes de calabozo
- [ ] Mundo expandido

---

## 🎯 Checklist de Implementación

```
CORE SYSTEMS
✅ GameManager singleton
✅ SceneLoader con transiciones
✅ WorldMapController
✅ BattleController
✅ BattleCharacter system

CHARACTERS
✅ PlayerController (movimiento 8 dir)
✅ EnemyController (patrulla + combate)
✅ Interacción jugador-enemigo

BATTLE SYSTEM
✅ Turno basado
✅ Cálculo de daño
✅ IA enemiga básica
✅ Recompensas (EXP, oro)

UI/UX
⬜ Battle UI visual
⬜ Health bars animadas
⬜ Menús pausable
⬜ HUD exploración

ASSETS
⬜ Sprites jugador
⬜ Sprites enemigos
⬜ Tileset
⬜ Música y SFX

PULIDO
⬜ Transiciones suaves
⬜ Efectos visuales
⬜ Sonido ambiente
⬜ Feedback visual/audio

TESTING
⬜ Transiciones bug-free
⬜ Sin memory leaks
⬜ Gameplay completo
⬜ Balance de dificultad
```

---

## 📝 Notas Importantes

### Por qué Esta Arquitectura?

1. **Desacoplamiento**: Las escenas no saben una de la otra
   - Cambiar WorldMap no afecta a BattleScene
   - Agregar nuevos sistemas es trivial

2. **Reusabilidad**: Los componentes se pueden usar en múltiples contextos
   - BattleCharacter podría usarse en un RPG turnado
   - PlayerController podría usarse en otro juego de exploración

3. **Testabilidad**: Fácil de probar
   - BattleCharacter no tiene dependencias visuales
   - Lógica separada de presentación

4. **Performance**: Optimizado para Godot 4
   - CharacterBody2D para física
   - RefCounted para datos puros
   - Carga asincrónica de escenas

### Optimizaciones Futuras

- Pool de objetos para enemigos repetidos
- LOD (Level of Detail) para enemigos lejanos
- Caché de pathfinding
- Compresión de datos guardados
- Precarga asincrónica de assets

---

## 📚 Referencias

- [Documentación Godot 4](https://docs.godotengine.org)
- [GDScript Best Practices](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Game Patterns by Robert Nystrom](https://gameprogrammingpatterns.com/)
- [Secret of Evermore (Referencia de Inspiración)](https://en.wikipedia.org/wiki/Secret_of_Evermore)

---

**Versión**: 0.1.0  
**Última Actualización**: Mayo 2026  
**Autor**: Senior Gameplay Programmer
