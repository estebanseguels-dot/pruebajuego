# 🎮 Hoja de Trucos - Referencia Rápida

## 📌 Acceso a Singletons (Disponibles desde cualquier parte)

```gdscript
# GameManager - Estado global del juego
GameManager.player_data          # Dict con HP, EXP, Level, etc.
GameManager.current_encounter    # Dict con enemigos de encuentro
GameManager.start_encounter(enemies, difficulty)
GameManager.end_encounter(victory, exp, loot)
GameManager.save_game()
GameManager.load_game()
GameManager.get_player_data()

# SceneLoader - Transiciones entre escenas
await SceneLoader.load_scene(path, transition_type)
SceneLoader.TransitionType.FADE
SceneLoader.TransitionType.SLIDE_LEFT
SceneLoader.TransitionType.NONE
SceneLoader.is_transitioning()
```

---

## 🎯 Flujo Principal de Código

### 1️⃣ Exploración (PlayerController)

```gdscript
# Movimiento automático con input
func _process(delta: float) -> void:
    var input_direction = Vector2.ZERO
    input_direction.x = Input.get_axis("ui_left", "ui_right")
    input_direction.y = Input.get_axis("ui_up", "ui_down")
    
    move_and_slide()
```

### 2️⃣ Detección de Enemigo

```gdscript
# En PlayerController
func _on_interaction_area_entered(area: Area2D) -> void:
    if area.is_in_group("enemy"):
        area.trigger_encounter()

# En EnemyController
func trigger_encounter() -> void:
    var enemy_data = {"type": enemy_type, "level": level, ...}
    GameManager.start_encounter([enemy_data], level)
```

### 3️⃣ Transición a Batalla

```gdscript
# GameManager.start_encounter() hace automáticamente:
# 1. Guarda posición del jugador
# 2. Fade out (0.5s)
# 3. Carga BattleScene
# 4. Fade in (0.5s)
# 5. Emite señal player_entered_battle
```

### 4️⃣ Sistema de Combate

```gdscript
# BattleController inicializa:
# - Personajes (BattleCharacter)
# - UI (BattleUI)
# - Orden de turnos

# Flujo:
# 1. Jugador selecciona acción
# 2. Calcular y aplicar daño
# 3. Enemigos atacan
# 4. Verificar fin de batalla
# 5. Entregar recompensas
```

### 5️⃣ Vuelta a Exploración

```gdscript
# GameManager.end_encounter() hace automáticamente:
# 1. Actualiza player_data (EXP, Gold)
# 2. Verifica level-up
# 3. Fade out batalla
# 4. Carga WorldMap
# 5. Restaura posición del jugador
# 6. Restaura HP del jugador
# 7. Fade in
```

---

## 🔧 Configuración Común

### Cambiar Velocidad del Jugador
```gdscript
# En player_controller.gd
@export var speed: float = 150.0  # Por defecto 100.0
```

### Cambiar Dificultad de Enemigo
```gdscript
# En enemy_controller.gd
@export var health: int = 50      # Por defecto 20
@export var attack: int = 10      # Por defecto 5 + level * 2
```

### Cambiar Fórmula de Daño
```gdscript
# En battle_character.gd
func calculate_damage(target: BattleCharacter) -> int:
    var base = attack - target.defense  # Puedes modificar aquí
    return max(1, base)
```

### Cambiar Transición de Escenas
```gdscript
# Donde llamas SceneLoader.load_scene()
await SceneLoader.load_scene(
    path,
    SceneLoader.TransitionType.SLIDE_LEFT  # Cambiar aquí
)
```

---

## 📊 Estructura de Datos

### Player Data (GameManager)
```gdscript
player_data = {
    "hp": 100,           # Salud actual
    "max_hp": 100,       # Salud máxima
    "exp": 0,            # Experiencia
    "level": 1,          # Nivel actual
    "gold": 0,           # Oro
    "position": Vector2(100, 100),  # Posición en mundo
    "scene": "res://src/scenes/world_map/world_map.tscn"
}
```

### Enemy Data (para encuentro)
```gdscript
enemy_data = {
    "type": "Slime",           # Nombre del enemigo
    "level": 1,                # Nivel
    "health": 20,              # HP
    "max_health": 20,          # HP máx
    "attack": 8,               # Ataque
    "defense": 2,              # Defensa
    "speed": 10,               # Velocidad (determina turno)
    "exp_reward": 50,          # EXP al derrotar
    "gold_reward": 25          # Gold al derrotar
}
```

### Encounter (encuentro actual)
```gdscript
current_encounter = {
    "enemies": [enemy_data_1, enemy_data_2],  # Array de enemigos
    "difficulty": 1,              # Multiplicador de dificultad
    "rewards_exp": 100,           # EXP total del encuentro
    "rewards_gold": 50            # Gold total del encuentro
}
```

---

## 🎨 Animaciones Esperadas

### Jugador (AnimatedSprite2D)
```
idle_up, idle_down, idle_left, idle_right
walk_up, walk_down, walk_left, walk_right
```

### Enemigo (AnimatedSprite2D)
```
walk
alert
attack (opcional)
die (opcional)
```

---

## 🔌 Señales Disponibles

### GameManager
```gdscript
signal player_entered_battle        # Al entrar a batalla
signal battle_finished(victory, exp, loot)  # Al terminar batalla
signal scene_transition_started     # Inicio transición
signal scene_transition_finished    # Fin transición
```

### BattleUI
```gdscript
# Emitidas automáticamente por botones
# Maneja mediante:
button.pressed.connect(_on_button_pressed)
```

---

## 🐛 Debug Rápido

### Ver logs en consola
```
View > Toggle Debug Renderer (F9)
```

### Print statements clave
```gdscript
print("[GameManager] Jugador level-up a %d" % player_data["level"])
print("[Battle] Daño: %d" % damage)
print("[WorldMap] Enemigo spawneado en %s" % enemy.global_position)
```

### Ver estado del jugador
```gdscript
print(GameManager.get_player_data())
```

---

## 🚀 Comandos Útiles de Godot

| Atajo | Función |
|-------|---------|
| **F5** | Play (Ejecutar juego) |
| **F6** | Play de escena actual |
| **F7** | Play pausado |
| **Ctrl+D** | Duplicar nodo/escena |
| **Ctrl+K** | Búsqueda rápida |
| **Ctrl+Shift+O** | Abrir archivo |
| **F2** | Renombrar |

---

## 📈 Valores de Balance Recomendados

### Jugador (Base, Level 1)
```
HP:      100
Attack:  10
Defense: 5
Speed:   15
```

### Enemigo Débil (Slime)
```
HP:      20
Attack:  8
Defense: 2
Speed:   10
EXP:     50
Gold:    25
```

### Enemigo Medio (Goblin)
```
HP:      35
Attack:  12
Defense: 4
Speed:   12
EXP:     75
Gold:    40
```

### Enemigo Fuerte (Orc)
```
HP:      50
Attack:  15
Defense: 6
Speed:   14
EXP:     100
Gold:    60
```

### Boss (Dragon)
```
HP:      150
Attack:  20
Defense: 10
Speed:   16
EXP:     300
Gold:    150
```

---

## 💾 Guardado/Cargado

### Guardar Datos Actuales
```gdscript
GameManager.save_game()
```

### Cargar Datos Guardados
```gdscript
if GameManager.load_game():
    print("Juego cargado")
else:
    print("Error al cargar")
```

---

## 🎯 Checklist pre-release

```
✅ Transiciones funcionan correctamente
✅ Datos se preservan entre escenas
✅ Combate termina correctamente
✅ Recompensas se otorgan
✅ Level-up funciona
✅ No hay memory leaks
✅ FPS constante 60
✅ Sin errores en consola
```

---

## 📞 Contacto Rápido

| Componente | Archivo |
|-----------|---------|
| GameManager | `src/managers/game_manager.gd` |
| SceneLoader | `src/core/scene_loader.gd` |
| WorldMapController | `src/scenes/world_map/world_map_controller.gd` |
| PlayerController | `src/characters/player/player_controller.gd` |
| EnemyController | `src/characters/enemy/enemy_controller.gd` |
| BattleController | `src/scenes/battle/battle_controller.gd` |
| BattleCharacter | `src/systems/battle_character.gd` |
| BattleUI | `src/ui/battle_ui/battle_ui.gd` |

---

**Última actualización**: Mayo 2026  
**Version**: 0.1.0

¡Feliz desarrollo! 🎮✨
